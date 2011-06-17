From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2 udp multicast packet loss and jtter
Date: Fri, 17 Jun 2011 18:55:18 +0200
Message-ID: <1308329718.3539.22.camel@edumazet-laptop>
References: <BANLkTimCgWSANaje4aBE5gQdwKWNRJX40A@mail.gmail.com>
	 <1308324641.3539.1.camel@edumazet-laptop>
	 <BANLkTimNG0Tk4iPEZTMnUXpaZxcR3ZkLVw@mail.gmail.com>
	 <1308325964.3539.14.camel@edumazet-laptop>
	 <BANLkTi=j_yYaNTeSfjqtOUnNoZRymAK32A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kieran Kunhya <kierank@ob-encoder.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37310 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab1FQQzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 12:55:23 -0400
Received: by wyb38 with SMTP id 38so452876wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 09:55:21 -0700 (PDT)
In-Reply-To: <BANLkTi=j_yYaNTeSfjqtOUnNoZRymAK32A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 juin 2011 =C3=A0 17:42 +0100, Kieran Kunhya a =C3=A9crit=
 :

> The analyzer can either use the RTP definition of jitter, or it uses
> its own algorithm to attempt to
> mimic the RTP definition of jitter when using TS packets in UDP by
> using the continuity counter.
> This happens with both UDP and RTP streams. (though for unrelated
> reasons UDP is usually used)
>=20
> The analyzer is on a different machine. The UDP thread isn't bottlene=
cked at all
> and the machine is only under moderate load. It also happens with man=
y
> different applications
> that can serve mpegts files.

Quite frankly, I cant believe your bnx2 can be responsible of jitters
like that. By the way, check you're on full duplex mode, not on half
duplex.

You could take a tcpdump on the sender machine, to check if delays are
on this machine, or later in your network (a congestioned egress
somewhere)



