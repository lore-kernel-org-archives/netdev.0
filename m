From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 11:37:19 +0200
Message-ID: <1273225039.2261.32.camel@edumazet-laptop>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273210774.2222.45.camel@edumazet-laptop>
	 <1273219222.2261.11.camel@edumazet-laptop>
	 <n2u571fb4001005070159y91d8b13crb20d2f14ea26dd1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Bhaskar Dutta <bhaskie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50284 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069Ab0EGJhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 05:37:24 -0400
Received: by bwz19 with SMTP id 19so458540bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 02:37:22 -0700 (PDT)
In-Reply-To: <n2u571fb4001005070159y91d8b13crb20d2f14ea26dd1a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 14:29 +0530, Bhaskar Dutta a =C3=A9crit =
:

> Eric,
>=20
> Thanks a lot! I will test it out and let you know.
> BTW this patch seems to essentially do the same as the earlier fix yo=
u
> had posted (where you just do bh disable/enable).
> Am I missing something?
>=20
> With the earlier fix, I ran load tests with 80 TCP connections for
> over 6 hrs and found 5 bad checksum packets.
> So there is still a problem. Without the fix I see a bad packet every
> minute or so.

My second patch is cleaner, using only out of line code (inline was not
necessary and made include file bigger than necessary). Inline is fine
if we can avoid a function call, but it was not the case.

If you notice another corruption, it may be because of another problem,
yet to be discovered.

To you have a userland suite to test/stress tcp md5 connections ?



