From: Speedster <speedster@haveacry.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Wed, 07 Jan 2009 06:19:58 +0900
Message-ID: <4963CAFE.4030800@haveacry.com>
References: <bug-12327-10286@http.bugzilla.kernel.org/> <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com> <20090102083402.GA24383@gondor.apana.org.au> <4961ECD2.1000502@haveacry.com> <Pine.LNX.4.64.0901062106340.26105@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted04.westnet.com.au ([203.10.1.217]:59764 "EHLO
	hosted04.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbZAFVUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 16:20:04 -0500
In-Reply-To: <Pine.LNX.4.64.0901062106340.26105@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
>>
>> I have tried both virtio and the default (8139too).
>=20
> And what is the actual eth hw on the host?
>=20

Currently r8169.

speedster@whimper:~$ sudo ethtool -i eth1
driver: r8169
version: 2.3LK-NAPI
firmware-version:
bus-info: 0000:03:01.0

eth0 (currently unused) is a r8168 but uses the same driver.

>> The original dumps were taken on whinge, I have attached two new dum=
ps=20
>> showing the functional (2.6.24) and non-functional (2.6.27) states=20
>> from the host.
>=20
> At least to me those didn't reveal anything new :-(.
>=20

:-(

Dean
