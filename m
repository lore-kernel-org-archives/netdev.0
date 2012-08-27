From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Gianfar ethernet drop package
Date: Mon, 27 Aug 2012 04:08:58 -0700
Message-ID: <1346065738.2420.135.camel@edumazet-glaptop>
References: <5037A86E.2000004@efacec.com>
	 <1345832223.19483.75.camel@edumazet-glaptop>  <503B4CBB.1020405@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?An=EDbal?= Almeida Pinto <anibal.pinto@efacec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46398 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab2H0LJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 07:09:02 -0400
Received: by pbbrr13 with SMTP id rr13so7246537pbb.19
        for <netdev@vger.kernel.org>; Mon, 27 Aug 2012 04:09:02 -0700 (PDT)
In-Reply-To: <503B4CBB.1020405@efacec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-27 at 11:32 +0100, An=C3=ADbal Almeida Pinto wrote:

> I generate the log on the board with tcpdump -i eth0 -w log_eth0.txt =
and=20
> loaded the result on wireshark (on other pc).
>=20
> On the wireshark everything appears to be fine don't have nothing tha=
t=20
> indicate the protocol isn't supported.
>=20
> On /etc/protocols is a list with protocols, it there is a place where=
=20
> exist a place with protocols supported by kernel ?

So all frames understood by wireshark are also automatically handled by
your linux machine ? That sounds cool, so we no longer have to add stuf=
f
in the kernel ?

Let me explain again :

=46or example, if you dont have IPv6 loaded, IPv6 frames wont be handle=
d,
and they appear to be dropped. They really are.

If you run tcpdump/wireshark, these frames are at least delivered once
to a sniffer, so they are not "dropped", even if no protocol handler
actually reacts to them.
