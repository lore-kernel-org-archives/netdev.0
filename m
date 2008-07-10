From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 13:11:28 -0700
Message-ID: <48766CF0.1020101@hp.com>
References: <4876668C.8040108@limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Dan_No=E9?= <dnoe@limebrokerage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:18189 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbYGJULb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 16:11:31 -0400
In-Reply-To: <4876668C.8040108@limebrokerage.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan No=E9 wrote:
> We're trying to troubleshoot some problems and we'd like to use the=20
> struct tcp_info method to gain some information and attempt to detect=
=20
> TCP loss events on the receiving side of a TCP stream.  The problem i=
s=20
> struct tcp_info is not well documented and my attempts to trace it se=
em=20
> to reveal that most of the statistics are relevant to the sending sid=
e=20
> of a TCP connection.
>=20
> Are there any fields (or any other way) to easily detect loss events?=
=20
> We're mostly concerned with detecting when TCP loss or reordering del=
ays=20
> things resulting in additional latency.

If this is just for troubleshooting, why not just take a tcpdump trace?

rick jones
