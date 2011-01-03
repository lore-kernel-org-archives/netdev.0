From: Rob Landley <rlandley@parallels.com>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Mon, 3 Jan 2011 14:48:47 -0600
Message-ID: <4D22362F.2040604@parallels.com>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>	 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>	 <20101230085139.GA29697@shutemov.name> <4D1C4C7C.6050606@parallels.com>	 <20101230094433.GB29697@shutemov.name>  <4D1C5953.6020200@parallels.com> <1293814441.2980.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirill A. Shutemov" <kas@openvz.org>,
	Rob Landley <rob@landley.net>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Pavel Emelyanov <xemul@parallels.com>,
	<linux-nfs@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293814441.2980.4.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/31/2010 10:54 AM, Trond Myklebust wrote:
>> I'm kind of surprised that the kernel cares about a specific path under
>> /var/lib.  (Seems like policy in the kernel somehow.)  Can't it just
>> check the current process's mount list to see if an instance of
>> rpc_pipefs is mounted in the current namespace the way lxc looks for
>> cgroups?  Or are there potential performance/scalability issues with that?
>
> The kernel doesn't give a damn about the /var/lib/nfs/rpc_pipefs bit.
> That's all for the benefit of the userland utilities.

Are you saying that if you go into a container and that mount point 
doesn't exist, the kernel will still be able to find and use rpc_pipefs? 
  Without userspace creating a specific magic path and mounting a 
filesystem on it?

If so, I misread the patch...

Rob
