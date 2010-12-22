From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Help: major pppoe regression since 2.6.35 (panic on first ppp
	conection)?
Date: Wed, 22 Dec 2010 11:00:21 +0000
Message-ID: <20101222110021.GA8985@ff.dom.local>
References: <20101222002215.fb0bfe95.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Soete <soete.joel@scarlet.be>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101222002215.fb0bfe95.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-12-22 09:22, Andrew Morton wrote:
> (cc netdev)
> 
> The bug is still present in 2.6.37-rc6.
> 
> On Sat, 18 Dec 2010 11:33:14 +0000 Joel Soete <soete.joel@scarlet.be> wrote:
> 
>> Hello all,

Hi,
Could you reproduce this bug with a vanilla kernel (without nvidia
patch)? If so, please include dmesg and .config to the next report.

Cheers,
Jarek P.

...
>> Dec 17 17:28:12 sidh2 kernel: [  106.511762] BUG: unable to handle kernel NULL pointer dereference at (null)
>> Dec 17 17:28:12 sidh2 kernel: [  106.511952] IP: [<ffffffff810e405b>] put_page+0x1b/0x180
>> Dec 17 17:28:12 sidh2 kernel: [  106.512078] PGD 13c6f0067 PUD 134283067 PMD 0
>> Dec 17 17:28:12 sidh2 kernel: [  106.512293] Oops: 0000 [#1] SMP
>> Dec 17 17:28:12 sidh2 kernel: [  106.512456] last sysfs file: /sys/devices/virtual/sound/timer/uevent
>> Dec 17 17:28:12 sidh2 kernel: [  106.512533] CPU 4
>> Dec 17 17:28:12 sidh2 kernel: [  106.512584] Modules linked in: ppdev xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle ip_tables 
>> x_tables lp nvidia(P) parport_pc parport agpgart i7core_edac edac_core tpm_tis tpm tpm_bios [last unloaded: scsi_wait_scan]
>> Dec 17 17:28:12 sidh2 kernel: [  106.513674]
>> Dec 17 17:28:12 sidh2 kernel: [  106.513742] Pid: 1821, comm: pppd Tainted: P            2.6.35-amd64-t3 #5 EX58-UD3R/EX58-UD3R
...
