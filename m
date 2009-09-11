From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Add IFA_F_DADFAILED flag
Date: Fri, 11 Sep 2009 12:38:11 -0700 (PDT)
Message-ID: <20090911.123811.168070421.davem@davemloft.net>
References: <4AA1C0FF.4030109@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756238AbZIKThy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:37:54 -0400
In-Reply-To: <4AA1C0FF.4030109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 04 Sep 2009 21:38:07 -0400

> [Note: if this is accepted I'll send out a patch for iproute,
>  if you'd prefer to not use the last ifa_flag I'll send a
>  much larger patch that does this differently :) ]
> 
> 
> Add IFA_F_DADFAILED flag to denote an IPv6 address that has
> failed Duplicate Address Detection, that way tools like
> /sbin/ip can be more informative.
> 
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 2001:db8::1/64 scope global tentative dadfailed 
>        valid_lft forever preferred_lft forever
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

I applied the most recent iteration of this patch using
the above commit message, thanks Brian.
