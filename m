From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 18:17:01 +0200
Message-ID: <1307722621.4044.17.camel@edumazet-laptop>
References: <4DF0E638.2010506@uth.tmc.edu>
	 <1307714177.4044.4.camel@edumazet-laptop> <4DF233CE.5020000@uth.tmc.edu>
	 <4DF24154.3060505@uth.tmc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63470 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab1FJQRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 12:17:05 -0400
Received: by wya21 with SMTP id 21so1977034wya.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 09:17:04 -0700 (PDT)
In-Reply-To: <4DF24154.3060505@uth.tmc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 11:07 -0500, Charles Bearden a =C3=A9cr=
it :

> You are correct: the checksums in the keepalives are broken, though t=
hey are=20
> correct in the other segments from the Win2008 server. I have updated=
 the pastes=20
> linked to above with 'tcpdump -v' output. I apologize for missing tha=
t problem=20
> the first time around.

Hmm, maybe its OK : If checksums are offloaded to NIC, tcpdump 'lies'
telling checksum is not OK, since tcpdump get a copy of the packet
before being handled by the NIC.

You should take a tcpdump on the receiving machine (the machine that
apparently doesnt react to the keepalive probes)


