From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Fri, 02 Mar 2007 00:14:37 +0100
Message-ID: <45E75E5D.9070508@cosmosbay.com>
References: <45E5570E.7050301@free.fr>	<200702281555.10309.dada1@cosmosbay.com>	<45E5A8AE.3030606@free.fr>	<200703011230.50596.dada1@cosmosbay.com> <20070301105348.04c2fd82@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John find <linux.kernel@free.fr>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60368 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161239AbXCAXOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 18:14:54 -0500
In-Reply-To: <20070301105348.04c2fd82@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :

>=20
> You probably want to add a SO_TIMESTAMPNS setsockopt() value like exi=
sting SO_TIMESTAMP

You mean an alias like this ?

#define SO_TIMESTAMPNS SO_TIMESTAMP

Or should we really use another value ?

>=20
> Also use NSEC_PER_USEC rather than hardcoded 1000.
>=20
>=20

Yes I will resubmit a patch including your suggestions (I discovered so=
me=20
missing bits after a make allyesconfig)

Thank you

