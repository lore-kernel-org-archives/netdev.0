From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 08:14:13 +0200
Message-ID: <49780EB5.60300@iki.fi>
References: <20090121223329.GA8522@gondor.apana.org.au>	<20090121.144054.70937985.davem@davemloft.net>	<49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:54666 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbZAVGOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 01:14:19 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2037731fgg.17
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 22:14:18 -0800 (PST)
In-Reply-To: <20090121.220304.211246256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 22 Jan 2009 07:56:57 +0200
>=20
>> Is there any particular reason why setting NAT-OA info should/
>> must be done using netlink? Or is this just a way to try to
>> put more pressure for the change to happen?
>=20
> Because it isn't deprecated if we keep adding features to it.

I would not consider this a new feature. It just makes pfkey
act consistently. If you don't want it supported, it'd make
more sense to not #define SADB_X_EXT_NAT_T_OA and drop all of
the verification code already present than to silently
ignore it. Make kernel return an error if some tried using it.

Now you give impression that it's supported but you just drop
it silently.

>> Also I find it a bit confusing which things are to be allowed
>> in pfkey and which not. We've had bigger fixes/changes to pfkey
>> in past like MIGRATE rewrite, etc.
>=20
> That was a mistake on my part, I shouldn't have allowed the
> pfkey side of the changes there.

I see.

- Timo
