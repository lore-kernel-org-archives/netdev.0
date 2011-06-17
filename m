From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2 udp multicast packet loss and jtter
Date: Fri, 17 Jun 2011 17:30:41 +0200
Message-ID: <1308324641.3539.1.camel@edumazet-laptop>
References: <BANLkTimCgWSANaje4aBE5gQdwKWNRJX40A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kieran Kunhya <kierank@ob-encoder.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53696 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759410Ab1FQPaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 11:30:46 -0400
Received: by wyb38 with SMTP id 38so400276wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 08:30:45 -0700 (PDT)
In-Reply-To: <BANLkTimCgWSANaje4aBE5gQdwKWNRJX40A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 11 juin 2011 =C3=A0 15:32 +0100, Kieran Kunhya a =C3=A9crit :
> Hello,
>=20
> I get some bad packet loss and high jitter on a BCM5709. This is on
> kernel 2.6.38-8 - unfortunately using a newer kernel isn't an option
> right now.
> The bnx2 driver is version v2.0.23b.
>=20
> I've tried a lot of kenel types such as -lowlatency, -ck and vanilla.
> The thread doing the udp output is at realtime priority and the same
> thing happens with different applications.
>=20
> Example of jitter
> http://dl.dropbox.com/u/2701213/jitter.png
>=20
> Is there anything I can do to further diagnose this problem?
>=20

Hi

How is this jitter measured ?

Is the link otherwise idle, or do you have a particular qdisc setup to
make sure packets from other flow wont have an effect ?



