From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: 3.7-rc2 regression : file copied to CIFS-mounted directory
 corrupted
Date: Tue, 23 Oct 2012 02:20:18 -0700 (PDT)
Message-ID: <636804155.6539897.1350984018386.JavaMail.root@vmware.com>
References: <1350983152.8609.1635.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	edumazet@google.com, "VMware, Inc." <pv-drivers@vmware.com>,
	jongman heo <jongman.heo@samsung.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350983152.8609.1635.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric, thanks for the note. I will submit a patch to do it.

Shreyas

----- Original Message -----
> On Tue, 2012-10-23 at 08:17 +0000, Jongman Heo wrote:
> 
> > 
> > FYI, vmxnet3 driver is used for ethernet.
> 
> Yes, this driver needs some changes
> 
> #define VMXNET3_MAX_TX_BUF_SIZE  (1 << 14)
> 
> Thats 16KB
> 
> As we can now provide up to 32KB fragments we broke something.
> 
> vmxnet3_tq_xmit() needs to split large frags into 2 parts.
> (And without going to skb_linearize() of course !)
> 
> Any volunteer ?
> 
> Thanks !
> 
> 
> 
