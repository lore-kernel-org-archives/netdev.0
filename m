From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 11:36:29 +0200
Message-ID: <4A24F29D.1090106@dev.6wind.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601.190430.80366622.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:3714 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbZFBJg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:36:28 -0400
In-Reply-To: <20090601.190430.80366622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
> Date: Mon, 01 Jun 2009 17:13:43 +0200
> 
>> RFC indicates that a router must drop the packet if this field is 0.
> 
> It only must do this when executing the forwarding function.  It's an
> egress check, not an ingress one.
In my understanding, it can be on input to:
RFC4443 Section 3.3:
    If a router receives a packet with a Hop Limit of zero, or if a
    router decrements a packet's Hop Limit to zero, it MUST discard the
    packet and originate an ICMPv6 Time Exceeded message with Code 0 to
    the source of the packet.

> 
> I'm not applying this patch, it can even break some applications
> out there that use a TTL of zero intentionally to keep traffic
> only on a local subnet.
OK ok. John sends good arguments ;-)


Nicolas

