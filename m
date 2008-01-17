From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 09:38:15 +0200
Message-ID: <478F05E7.6070503@iki.fi>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>	<478EF542.1010702@iki.fi> <20080116.231654.74131878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:48315 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbYAQHhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 02:37:03 -0500
Received: by fg-out-1718.google.com with SMTP id e21so575671fga.17
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 23:37:01 -0800 (PST)
In-Reply-To: <20080116.231654.74131878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo_Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 17 Jan 2008 08:27:14 +0200
>=20
>> I don't know about netlink. But pfkey works in *BSD too and it is RF=
C'd.
>> So I'd say pfkey might be a bit more portable. Though netlink is def=
initely
>> more robust and extensive.
>=20
> The RFCs say absolutely nothing about policy interfaces for AF_KEY,
> everybody rolls their own in slightly incompatible ways.
>=20
> It is therefore anything but standardized.

Yes, there's non-standardized extensions. But the point was that there =
are
other implementations of pfkey. And ipsec-tools racoon is an example of
a widely used application that runs in Linux and *BSD using this API. S=
o
for the time being I'd consider having pfkey fixes as a good thing. Thi=
s
pfkey dumping problem seems to be affecting many users.

- Timo
