From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3.4-stable] ipv6: reallocate addrconf router for ipv6
 address when lo, device up
Date: Tue, 5 Aug 2014 11:18:33 -0700
Message-ID: <20140805181833.GB9959@kroah.com>
References: <53A0173F.8090107@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	Li Zefan <lizefan@huawei.com>
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:52647 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478AbaHESSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 14:18:35 -0400
Content-Disposition: inline
In-Reply-To: <53A0173F.8090107@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 06:23:59PM +0800, chenweilong wrote:
> Hi Greg,
> 
> Please queue this for 3.4 stable kernel.
> 
> It fix the bug 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=67951
> 
> The patch can't be applied directly, as it' used the function introduced
> by "commit 94e187c0" ip6_rt_put(), that patch can't be applied directly
> either. So I had to write this one.

Now applied, can you also provide a version for 3.10-stable as I think
it is needd there also, right?

thanks,

greg k-h
