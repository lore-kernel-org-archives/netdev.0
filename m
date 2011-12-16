From: David Miller <davem@davemloft.net>
Subject: Re: nonlocal_bind and IPv6
Date: Fri, 16 Dec 2011 13:20:12 -0500 (EST)
Message-ID: <20111216.132012.625460188266025260.davem@davemloft.net>
References: <20111216.020600.1695776769736304587.davem@davemloft.net>
	<e21a2d9682b5d83fefe3f09a07316033@luffy.cx>
	<20111216111027.GA2315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bernat@luffy.cx, zenczykowski@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760133Ab1LPSXW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:23:22 -0500
In-Reply-To: <20111216111027.GA2315@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 16 Dec 2011 12:10:27 +0100

> Vincent Bernat <bernat@luffy.cx> :
>> On Fri, 16 Dec 2011 02:06:00 -0500 (EST), David Miller wrote:
>> >>04:58, Maciej =AFenczykowski <zenczykowski@gmail.com> disait=A0:
> [...]
>> >>>why not simply use the IP_TRANSPARENT or IP_FREEBIND socket
>> >>>options?
>> >>
>> >>Because  this requires  modifying each  affected software.  This
>> >>can be difficult if you don't have the source code available.
>> >
>> >But it means that it would work on every single kernel verion out
>> >there.
> [...]
>> Moreover, I am just adding the IPv6 version of this setting. The
>> IPv4 version already exists.
>=20
> For IPv6 this is adding a system-scope function which will have to be
> maintained and available for ages. It will compete with the existing,
> per-application answer. The "fix you application / design" argument
> is thus stronger than with IPv4.

Another excellent point.
