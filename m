From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing tc filters
Date: Sat, 10 Dec 2011 21:10:01 +0100
Message-ID: <1323547801.4016.34.camel@edumazet-laptop>
References: <1323540988.3159.133.camel@denise.theartistscloset.com>
	 <1323546064.4016.27.camel@edumazet-laptop>
	 <1323547080.3159.153.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42973 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab1LJUKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 15:10:10 -0500
Received: by eaak14 with SMTP id k14so2255923eaa.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 12:10:09 -0800 (PST)
In-Reply-To: <1323547080.3159.153.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 14:58 -0500, John A. Sullivan II=
I a =C3=A9crit :

> If we are using connection tracking in general to produce a "stateful=
"
> firewall (let's just say we are - I certainly don't want to set off a
> debate :) ), does that put #1 back on top as the most efficient since=
 we
> are incurring the conntrack overhead anyway or does the CONNMARK targ=
et
> itself add considerable overhead? Thanks - John
>=20

CONNMARK is very cheap, no extra overhead.
