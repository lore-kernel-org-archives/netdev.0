From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rt6_probe_deferred: Do not depend on struct ordering
Date: Sun, 08 Feb 2015 13:03:10 -0800 (PST)
Message-ID: <20150208.130310.111499727183236845.davem@davemloft.net>
References: <20150208101407.517bcfa7@wiggum>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: m@bues.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbBHVDS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 16:03:18 -0500
In-Reply-To: <20150208101407.517bcfa7@wiggum>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michael B=FCsch <m@bues.ch>
Date: Sun, 8 Feb 2015 10:14:07 +0100

> rt6_probe allocates a struct __rt6_probe_work and schedules a work ha=
ndler rt6_probe_deferred.
> But rt6_probe_deferred kfree's the struct work_struct instead of stru=
ct __rt6_probe_work.
> This works, because struct work_struct is the first element of struct=
 __rt6_probe_work.
>=20
> Change it to kfree struct __rt6_probe_work to not implicitly depend o=
n
> struct work_struct being the first element.
>=20
> This does not affect the generated code.
>=20
> Signed-off-by: Michael Buesch <m@bues.ch>

Applied.
