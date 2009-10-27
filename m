From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Tue, 27 Oct 2009 02:40:02 +0100
Message-ID: <4AE64F72.6060802@gmail.com>
References: <OF703F980D.0971407E-ON6525765B.00458CCA-6525765B.00481976@in.ibm.com>	<200910261631.44666.opurdila@ixiacom.com>	<4AE5B84E.8040505@gmail.com> <20091026.182429.55413765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: opurdila@ixiacom.com, krkumar2@in.ibm.com, hagen@jauu.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57639 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755613AbZJ0BkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 21:40:16 -0400
In-Reply-To: <20091026.182429.55413765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 26 Oct 2009 15:55:10 +0100
>=20
>> But should we really care ?
>=20
> The only thing I see consistently in this thread is that
> jhash performs consistently well and without any tweaking.
>=20
> And without any assumptions about the characteristics of
> the device names.  I've seen everything from the traditional
> "eth%d" to things like "davem_is_a_prick%d" so you really cannot
> optimize for anything in particular.
>=20
> Jenkins is ~50 cycles per round of 4 bytes last time I checked, give
> or take, and that was on crappy sparc. :-) So the execution cost is
> really not that bad, contrary to what I've seen claimed as an argumen=
t
> against using jhash here.
>=20
> And if I-cache footprint is really an issue, we can have one
> out-of-line expansion of jhash somewhere under lib/ since we use jhas=
h
> in so many places these days.

Well, since Stephen posted a generic patch on lkml, I suspect we'll tak=
e
the dcache hash anyway ?

But yes, last time I checked, jhash was pretty big, so an out-of-line
version is welcome :)
