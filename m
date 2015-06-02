From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg and
 sendmsg
Date: Tue, 2 Jun 2015 10:21:54 +0900
Message-ID: <20150602012154.GB23370@kroah.com>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lizefan@huawei.com, viro@zeniv.linux.org.uk, davem@davemloft.net,
	xuhanbing@huawei.com, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Junling Zheng <zhengjunling@huawei.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 01, 2015 at 09:28:00AM +0000, Junling Zheng wrote:
> Hi, Greg:
> 
> We found that after v3.10.73, recvmsg might return -EFAULT while -EINVAL
> was expected.

That means I messed up and applied something I shouldn't have, right?

Can you use 'git bisect' to find the problem patch?  That's probably
easier here, and then I can either revert it, or fix up a broken
backport.

thanks,

greg k-h
