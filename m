From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use the macros defined for the members of flowi
Date: Mon, 15 Nov 2010 22:57:18 +0100
Message-ID: <1289858238.3364.16.camel@edumazet-laptop>
References: <1289623435-22713-1-git-send-email-xiaosuo@gmail.com>
	 <4CE1A710.9040603@hp.com>  <1289857126.3364.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40542 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755605Ab0KOV5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 16:57:24 -0500
Received: by wyb28 with SMTP id 28so4892696wyb.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 13:57:23 -0800 (PST)
In-Reply-To: <1289857126.3364.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 novembre 2010 =C3=A0 22:38 +0100, Eric Dumazet a =C3=A9crit=
 :

> Same question on lkml few hours ago. I think gcc does the assignement=
 to
> zero, even on automatic variables (at least done on x86), but could n=
ot
> find a doc on it.

Oh well, for sure fields that are not mentioned are set to 0, thanks to
C99.

My question on lkml was about padding holes (security related)



