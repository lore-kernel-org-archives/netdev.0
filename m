From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 23:24:23 +0100
Message-ID: <1324679063.2915.18.camel@edumazet-laptop>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324651128.10184.586.camel@denise.theartistscloset.com>
	 <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324654013.10184.597.camel@denise.theartistscloset.com>
	 <1324656963.4540.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324658658.10184.613.camel@denise.theartistscloset.com>
	 <1324659976.4540.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324660666.4540.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324661598.10184.615.camel@denise.theartistscloset.com>
	 <1324661727.10184.617.camel@denise.theartistscloset.com>
	 <1324674615.10184.631.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@spiritualoutreach.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36924 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab1LWWY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 17:24:27 -0500
Received: by werm1 with SMTP id m1so4196773wer.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 14:24:26 -0800 (PST)
In-Reply-To: <1324674615.10184.631.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 16:10 -0500, John A. Sullivan =
III a
=C3=A9crit :

> Should I guess that, from the flood of subsequent emails about patchi=
ng
> netem that it is not currently possible to do netem and hfsc/sfq on
> ingress traffic using the currently available tools?=20
>=20

Yep... current netem is a bit limited.

> It's definitely netem on the ingress.  When I run it on egress and
> disable it on ingress, I do not have the problem.  But, I see no what=
 of
> getting the netem traffic into or out of SFQ.  Thanks - John
>=20

It'll be possible, after a few patches, but only using net-next, or
waiting a backport to a 3.2 kernel somehow...
