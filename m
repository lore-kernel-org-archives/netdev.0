From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 04 Jan 2011 08:33:27 +0100
Message-ID: <1294126407.2711.39.camel@edumazet-laptop>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
	 <1294125880.2711.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joel Sing <jsing@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33307 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897Ab1ADHdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 02:33:32 -0500
Received: by wwa36 with SMTP id 36so14908345wwa.1
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 23:33:30 -0800 (PST)
In-Reply-To: <1294125880.2711.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 08:24 +0100, Eric Dumazet a =C3=A9crit =
:

> Please use FIB_RES_PREFSRC(res)
>=20

Hmm no, this is not applicable, but this could be shorter :

fl.fl4_src =3D res.fi->fib_prefsrc ? : fl.fl4_dst;



