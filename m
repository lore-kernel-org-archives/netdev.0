From: Venkata Mohan Reddy <mohanreddykv@gmail.com>
Subject: Re: Help On function to get IPV6 address of an interface in kernel
Date: Fri, 5 Mar 2010 21:19:34 +0530
Message-ID: <20100305154932.GA5139@mohan-laptop>
References: <20100304094103.GA6599@mohan-laptop> <4B8FDD23.3070000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:44454 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab0CEPtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 10:49:49 -0500
Received: by fxm19 with SMTP id 19so4266971fxm.21
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 07:49:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B8FDD23.3070000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot Brain. ipv6_get_lladdr()  helped me. Actually I want to get site-local or univeral(global) address. Though there is no direct function to get theseaddresses, ipv6_get_lladdr() shows how we can get the other addresses too.

Thanks,
Mohan Reddy
  
On Thu, Mar 04, 2010 at 11:17:39AM -0500, Brian Haley wrote:
> Mohan Reddy wrote:
> > Hi,
> > 
> > Is there a function or a way in kernel to get an interface ipv6 address if interface name or net_device object is known? I searched in the kernel i got a function ipv6_get_ifaddr(). But it is expecting an ipv6 address as a parameter. 
> 
> What type of IPv6 address?  For link-locals you can use ipv6_get_lladdr(), but
> for others ipv6_dev_get_saddr() is more comprehensive, but you'll need a
> destination address.  There's lots of reference code in addrconf.c to do
> other things.
> 
> -Brian
