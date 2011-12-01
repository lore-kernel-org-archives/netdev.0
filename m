From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: Is there any necessary to add multicast route for a loopback
 device?
Date: Thu, 01 Dec 2011 10:30:00 +0800
Message-ID: <4ED6E6A8.3080702@cn.fujitsu.com>
References: <4ED5DD7D.10908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64998 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753289Ab1LAC3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 21:29:41 -0500
In-Reply-To: <4ED5DD7D.10908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

what's your opinion?

> Hi all,
> 
> I found that since Fedora 15, it use systemd as the 'init'. When systemd start 
> it would config the ipv6 address(::1/128) for 'lo' and start it. While adding 
> this address to 'lo', kernel will call addrconf_add_mroute() to set a multicast
> route for 'lo' with rt->dst.error = -ENETUNREACH. After that, when I send multi-
> cast message, the route subsystem return a route with .error set to NETUNREACH.
> 
> Is there any necessary to add multicast route for a loopback device? 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
