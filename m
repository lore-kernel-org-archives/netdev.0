From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 14:21:11 +0200
Message-ID: <478F4837.3050509@iki.fi>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au> <1200533980.4451.100.camel@localhost> <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi> <20080117111106.GA8932@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:12480 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbYAQMT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 07:19:58 -0500
Received: by fg-out-1718.google.com with SMTP id e21so654567fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 04:19:56 -0800 (PST)
In-Reply-To: <20080117111106.GA8932@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 17, 2008 at 07:54:32AM +0200, Timo Ter=E4s wrote:
>>> Racoon doesn't use pfkey dumping as far as I know.
>> ipsec-tools racoon uses pfkey and only pfkey. And it's non trivial t=
o
>> make it use netlink; it relies heavily all around the code to pfkey
>> structs. It also runs on BSD so we cannot rip pfkey away; adding a
>> layer to work with both pfkey and netlink would be doable, but just =
a
>> lot of work.
>=20
> Sure racoon uses pfkey but the question is does it use pfkey dumping?

Yes it does.

It does SPD dump at startup and keeps the SP database in sync by
listening to notifications.

It also does SA dumps when it is figuring out which SAs to purge.

I started to work on the xfrm/pfkey patch only because racoon is
having problems with (as is anything else using pfkey).

- Timo

