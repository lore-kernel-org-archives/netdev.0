From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: nfs broken in net-next?
Date: Thu, 29 Oct 2009 12:32:32 +0530
Message-ID: <4AE93E08.3040506@suse.de>
References: <86802c440910281313h2ca89c94w99121edffbf6ce53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756575AbZJ2HCp@vger.kernel.org>
In-Reply-To: <86802c440910281313h2ca89c94w99121edffbf6ce53@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2009 01:43 AM, Yinghai Lu wrote:
> pk12-3214-189-102:~ # mount -t nfs 10.6.75.100:/data/shared/pxeboot /x
> mount.nfs: rpc.statd is not running but is required for remote locking.
> mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
> 

Is statd running on the server? The in-kernel statd has been replaced by
userspace statd.

> using opensuse11.1
> 
> YH
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
Suresh Jayaraman
