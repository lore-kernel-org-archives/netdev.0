From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: nfs broken in net-next?
Date: Thu, 29 Oct 2009 12:53:55 +0530
Message-ID: <4AE9430B.3060105@suse.de>
References: <86802c440910281313h2ca89c94w99121edffbf6ce53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756684AbZJ2HYG@vger.kernel.org>
In-Reply-To: <86802c440910281313h2ca89c94w99121edffbf6ce53@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2009 01:43 AM, Yinghai Lu wrote:
> pk12-3214-189-102:~ # mount -t nfs 10.6.75.100:/data/shared/pxeboot /x
> mount.nfs: rpc.statd is not running but is required for remote locking.
> mount.nfs: Either use '-o nolock' to keep locks local, or start statd.

rpc.statd on client should have be started by mount.nfs when a nfs
filesystem is mounted. Is this not happening for some reason or do you
see any errors in syslog?

> 
> using opensuse11.1
> 

Are you using 11.1 betas? I know of a problem where non-root user mounts
fail to start rpc.statd in betas that got fixed later:

http://marc.info/?l=linux-nfs&m=122748525624094&w=2

Is the problem seen only recently (after updating to net-next)?

Thanks,

-- 
Suresh Jayaraman
