From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] l2tp: give proper headroom in pppol2tp_xmit()
Date: Wed, 19 Oct 2011 06:24:49 +0200
Message-ID: <1318998289.19139.18.camel@edumazet-laptop>
References: <1318002357.3207.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018.233444.955647916101091708.davem@davemloft.net>
	 <1318996826.19139.11.camel@edumazet-laptop>
	 <20111019.001216.1105373017883639047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47713 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab1JSEYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:24:55 -0400
Received: by wyg36 with SMTP id 36so1298053wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 21:24:54 -0700 (PDT)
In-Reply-To: <20111019.001216.1105373017883639047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 00:12 -0400, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 19 Oct 2011 06:00:26 +0200
> >=20
> > Target of the patch is an embedded device, MIPS based.=20
> >=20
> > I am not sure perf is available on it.
>=20
> No MIPS specific code is needed to support perf tracepoint
> analysis features.
>=20

OK then I'll take a look, thanks for the hint !
