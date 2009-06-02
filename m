From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 02:37:51 -0700 (PDT)
Message-ID: <20090602.023751.68661975.davem@davemloft.net>
References: <4A23F027.3060907@dev.6wind.com>
	<20090601.190430.80366622.davem@davemloft.net>
	<4A24F29D.1090106@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755382AbZFBJhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:37:50 -0400
In-Reply-To: <4A24F29D.1090106@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 02 Jun 2009 11:36:29 +0200

> David Miller wrote:
>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>> Date: Mon, 01 Jun 2009 17:13:43 +0200
>> 
>>> RFC indicates that a router must drop the packet if this field is 0.
>> It only must do this when executing the forwarding function.  It's an
>> egress check, not an ingress one.
> In my understanding, it can be on input to:
> RFC4443 Section 3.3:
>    If a router receives a packet with a Hop Limit of zero, or if a
>    router decrements a packet's Hop Limit to zero, it MUST discard the
>    packet and originate an ICMPv6 Time Exceeded message with Code 0 to
>    the source of the packet.

I think this was unintentional.

Usage of zero TTL by multicast applications is very well established.

Running such an application on a router should work as well.
