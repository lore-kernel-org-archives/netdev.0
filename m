From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 16:41:28 +0200
Message-ID: <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1311946421.2843.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32C302.8050304@hippy.csoma.elte.hu>
	 <1311950184.2843.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110729.073910.59762029845942660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36389 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab1G2Olb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:41:31 -0400
Received: by wyg8 with SMTP id 8so225857wyg.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 07:41:30 -0700 (PDT)
In-Reply-To: <20110729.073910.59762029845942660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 07:39 -0700, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 29 Jul 2011 16:36:24 +0200
>=20
> > Hmm, I'll take a look, but check_peer_redir() seems suspicious at f=
irst
> > glance.
>=20
> I take full responsibility for any bugs you discover in it :-)


;)

Bug origin is commit f39925dbde7788cfb96419c0f092b086aa325c0f
ipv4: Cache learned redirect information in inetpeer.

I'll cook a patch ASAP


