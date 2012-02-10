From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 2.6.31.8 panic in neigh_hh_output
Date: Fri, 10 Feb 2012 09:16:42 +0100
Message-ID: <1328861802.4030.5.camel@edumazet-laptop>
References: <CAADzPW0U6JgSKFSD_q9RM_vv6x0RZ0-tOMZh8mrMk4d=fzZSYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=E6=99=81=E6=B0=B8=E7=94=9F?= <chaoys155@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:48664 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754026Ab2BJIQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 03:16:45 -0500
Received: by wics10 with SMTP id s10so1810676wic.19
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 00:16:44 -0800 (PST)
In-Reply-To: <CAADzPW0U6JgSKFSD_q9RM_vv6x0RZ0-tOMZh8mrMk4d=fzZSYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 15:56 +0800, =E6=99=81=E6=B0=B8=
=E7=94=9F a =C3=A9crit :
> I got a kernel panic on my uniprocessor ARM machine. backtrace as fol=
lows
>=20

> I thought it was due to memory corruption. So
> I checked the 64 bytes before hh_cache (0x98ba9580), it seems a nf_br=
idge_info;
> and the 64 bytes after hh_cache , it seems a pid.
> But the nf_bridge_info and pid both seem ok.
> I don't known what to do now. why the hh_cache was zeroed while
> neighbour is reachable?

There is very litle chance you can find help from us on this old kernel=
=2E

We already have lot of work to fix bugs in current kernels.

You should at least use 2.6.32.56 kernel to find some help.
