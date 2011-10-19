From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] l2tp: give proper headroom in pppol2tp_xmit()
Date: Wed, 19 Oct 2011 06:00:26 +0200
Message-ID: <1318996826.19139.11.camel@edumazet-laptop>
References: <1318002357.3207.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018.233444.955647916101091708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50963 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab1JSEAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:00:35 -0400
Received: by wwe6 with SMTP id 6so1889613wwe.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 21:00:34 -0700 (PDT)
In-Reply-To: <20111018.233444.955647916101091708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 23:34 -0400, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> > Maybe we should add a counter to help diagnose too many
> > pskb_expand_head() calls...
>=20

> I think it's the kind of event that deserves a tracepoint, this way o=
ne
> could use perf to notice and diagnose such problems.

Target of the patch is an embedded device, MIPS based.=20

I am not sure perf is available on it.

Thanks
