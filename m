From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 11:20:42 +0200
Message-ID: <478F1DEA.5070903@iki.fi>
References: <478F05E7.6070503@iki.fi>	<20080116.235923.208347316.davem@davemloft.net>	<478F0DA5.2060401@iki.fi> <20080117.004900.58497170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:53758 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbYAQJTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 04:19:32 -0500
Received: by fg-out-1718.google.com with SMTP id e21so604902fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 01:19:30 -0800 (PST)
In-Reply-To: <20080117.004900.58497170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo_Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 17 Jan 2008 10:11:17 +0200
>=20
>> I thought my patch would qualify as "life support" bug fix.
>> Currently racoon fails to work if there are too many SPDs or SAs
>> because the kernel cannot handle the dump request properly. And this
>> is what my patch fixes for pfkey. It adds no new features or
>> functionality; just makes the dumping work with large databases.
>=20
> Racoon should use netlink for reasons far and beyond the
> problem you are trying to address.

Yes. But this is fairly major thing to do. One needs to create
API abstraction layer (still need to use pfkey in *BSD). Test it.
A lot of work that is not going to happen very soon.

Where as the pfkey bug fix is non-intrusive and helps all
legacy applications still using af_key by _fixing a bug in
kernel_.

> The dumping behavior of AF_KEY is just horrific, as one of
> several examples.

If af_key is all that bad and does not qualify to get maintanace
bug fixes, why not remove it complitely?

That would make userland adapt faster.

>> Then there's also the xfrm dumping changes which change the
>> algorithm from O(n^2) to O(n) with some memory overhead, but
>> that is a different story. Any comments on that?
>=20
> I have no general objections to those changes although I am
> backlogged and thus have not studied them in detail.  Jamal
> is having what appears to be a healthy dialogue with you about
> the details so I'm not concerned much :)

Ok. I hope someone can also give feedback on the naming
conventions. And about the api changes to xfrm policy/state
walking.

- Timo

