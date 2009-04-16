From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: ROUTE:read ifname in rt6_info_route()
Date: Thu, 16 Apr 2009 04:38:00 -0700 (PDT)
Message-ID: <20090416.043800.171462037.davem@davemloft.net>
References: <49E710E1.3060209@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ysugiura@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33055
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751169AbZDPLiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 07:38:08 -0400
In-Reply-To: <49E710E1.3060209@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuta sugiura <ysugiura@miraclelinux.com>
Date: Thu, 16 Apr 2009 20:05:05 +0900

> Hi,
> I have a suggestion about /proc/net/IPv6_route format.
> In rt6_info_route(), interface name is treated as a maximum 8
> characters.
> But the type of (struct rt6_inf *)->u.dst.dev->name is char[IFNAMESIZ=
> 16]
> so, I think that it should change "%8s" to "%16s".

Isn't there a way to pass the field length as a paramenter
to formatting functions?  Then we can just pass in
IFNAMESIZE as that parameter.
