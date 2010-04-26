From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: GRO after RPS?
Date: Mon, 26 Apr 2010 09:40:35 +0800
Message-ID: <m2q412e6f7f1004251840vdf264f38vd0df335802cb2a91@mail.gmail.com>
References: <20100425.170933.190068177.davem@davemloft.net>
	<20100426004934.GA12525@gondor.apana.org.au> <20100425.181757.10149105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:65533 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab0DZBk4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 21:40:56 -0400
Received: by iwn8 with SMTP id 8so4526567iwn.16
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 18:40:55 -0700 (PDT)
In-Reply-To: <20100425.181757.10149105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 26, 2010 at 9:17 AM, David Miller <davem@davemloft.net> wro=
te:
>
> The goal is to eliminate all packet header references from the pre-RP=
S
> path, and let the post-RPS cpu do it.

If the NIC doesn't provide rxhash, RPS will have to compute one by one
by itself. Is the hash computation more expensive than GRO? I think
the hash computation is cheaper than GRO, so we can do RPS ASAP to
avoid the direct CPU overload.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
