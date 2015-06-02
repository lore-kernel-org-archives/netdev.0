From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg and
 sendmsg
Date: Tue, 2 Jun 2015 15:27:51 +0900
Message-ID: <20150602062751.GA3912@kroah.com>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
 <20150602012154.GB23370@kroah.com>
 <556D2B8C.9010108@huawei.com>
 <20150601.222357.122000161676177828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zhengjunling@huawei.com, lizefan@huawei.com,
	viro@zeniv.linux.org.uk, xuhanbing@huawei.com,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56494 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbFBG1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 02:27:54 -0400
Content-Disposition: inline
In-Reply-To: <20150601.222357.122000161676177828.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 01, 2015 at 10:23:57PM -0700, David Miller wrote:
> From: Junling Zheng <zhengjunling@huawei.com>
> Date: Tue, 2 Jun 2015 12:05:32 +0800
> 
> > So, the problem commit is 281c9c36 (net: compat: Update
> > get_compat_msghdr() to match copy_msghdr_from_user() behaviour),
> > which fixes db31c55a6fb2 and brings the get_compat_msghdr() in line
> > with copy_msghdr_from_user().
> 
> Upstream this got fixed by:
> 
> 08adb7dabd4874cc5666b4490653b26534702ce0
> 
> So the part that makes us not unconditionally return -EFAULT needs
> to be backported, and that's probably equivalent to the patch
> your proposed which therefore should be applied.

Ok, thanks, now applied.

greg k-h
