From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 18:49:05 +0200
Message-ID: <4A240681.2010300@6wind.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601161917.GA29745@Chamillionaire.breakpoint.cc>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:33817 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbZFAQtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2009 12:49:13 -0400
In-Reply-To: <20090601161917.GA29745@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01.06.2009 18:19, Florian Westphal a =E9crit :
> Nicolas Dichtel <nicolas.dichtel@dev.6wind.com> wrote:
>> when network stack receives a packet, it didn't check value of ttl/h=
op=20
>> limit
>> field. RFC indicates that a router must drop the packet if this fiel=
d is 0.
>=20
> Whats wrong with the checks in ip(6)_forward?
It's on forward, not on input. Router must not process it.
=46or example, if you try to ping (with ttl set to 0) the router, you w=
ill receive=20
a reply.

Nicolas
