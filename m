From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 04 Jan 2011 09:40:18 +0100
Message-ID: <1294130418.2711.49.camel@edumazet-laptop>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
	 <1294125880.2711.34.camel@edumazet-laptop>
	 <1294126407.2711.39.camel@edumazet-laptop>
	 <AANLkTimDms0FTmXWf9WSpcxwZXVVSXQj44jZ2Ag8Osuk@mail.gmail.com>
	 <1294130315.2711.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, Joel Sing <jsing@google.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44231 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab1ADIkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 03:40:24 -0500
Received: by wwa36 with SMTP id 36so14946542wwa.1
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 00:40:23 -0800 (PST)
In-Reply-To: <1294130315.2711.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 09:38 +0100, Eric Dumazet a =C3=A9crit =
:

> This could be properly done using another macro in include/net/ip_fib=
=2Eh
> to centralize this ternary op in one point :
>=20
> #define __FIB_RES_PREFSRC(res, default) ((res).fi->fib_prefsrc ? : de=
fault)
> #define FIB_RES_PREFSRC(res) __FIB_RES_PREFSRC(res, default, __fib_re=
s_prefsrc(&res)

I meant

#define FIB_RES_PREFSRC(res) __FIB_RES_PREFSRC(res, __fib_res_prefsrc(&=
res))



