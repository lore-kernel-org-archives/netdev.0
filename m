From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: Help On function to get IPV6 address of an interface in kernel
Date: Sun, 7 Mar 2010 09:53:02 +1030
Message-ID: <20100307095302.634fd08f@opy.nosense.org>
References: <20100304094103.GA6599@mohan-laptop>
	<4B8FDD23.3070000@hp.com>
	<20100305154932.GA5139@mohan-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Venkata Mohan Reddy <mohanreddykv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:54775 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab0CFXta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 18:49:30 -0500
In-Reply-To: <20100305154932.GA5139@mohan-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Mar 2010 21:19:34 +0530
Venkata Mohan Reddy <mohanreddykv@gmail.com> wrote:

> Thanks a lot Brain. ipv6_get_lladdr()  helped me. Actually I want to get site-local or univeral(global) address. Though there is no direct function to get theseaddresses, ipv6_get_lladdr() shows how we can get the other addresses too.
> 

Site-locals are deprecated (http://www.rfc-editor.org/rfc/rfc3879.txt),
so I wouldn't think you'll ever find a site-local specific address
function. If you do find one, I'd be fairly sure it'd go away.

> Thanks,
> Mohan Reddy
>   
> On Thu, Mar 04, 2010 at 11:17:39AM -0500, Brian Haley wrote:
> > Mohan Reddy wrote:
> > > Hi,
> > > 
> > > Is there a function or a way in kernel to get an interface ipv6 address if interface name or net_device object is known? I searched in the kernel i got a function ipv6_get_ifaddr(). But it is expecting an ipv6 address as a parameter. 
> > 
> > What type of IPv6 address?  For link-locals you can use ipv6_get_lladdr(), but
> > for others ipv6_dev_get_saddr() is more comprehensive, but you'll need a
> > destination address.  There's lots of reference code in addrconf.c to do
> > other things.
> > 
> > -Brian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
