From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] myri10ge: fix truesize underestimation
Date: Thu, 20 Oct 2011 22:44:02 +0200
Message-ID: <1319143442.2854.26.camel@edumazet-laptop>
References: <1319141403.2854.17.camel@edumazet-laptop>
	 <CAMaF-rN8K3hDiwwqh_eGQ0nrxskn+7r9Rn_yDJ46aesKR77nbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61529 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420Ab1JTUoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:44:08 -0400
Received: by wyg36 with SMTP id 36so3313420wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 13:44:06 -0700 (PDT)
In-Reply-To: <CAMaF-rN8K3hDiwwqh_eGQ0nrxskn+7r9Rn_yDJ46aesKR77nbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 15:33 -0500, Jon Mason a =C3=A9crit :
> On Thu, Oct 20, 2011 at 3:10 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > skb->truesize must account for allocated memory, not the used part =
of
> > it. Doing this work is important to avoid unexpected OOM situations=
=2E
> >
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Acked-by: Jon Mason <mason@myri.com>

Thanks for reviewing Jon !
