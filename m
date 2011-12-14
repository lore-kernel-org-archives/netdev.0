From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit
Date: Wed, 14 Dec 2011 23:31:49 +0100
Message-ID: <1323901909.2631.17.camel@edumazet-laptop>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
	 <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <C2C333F1-98FD-41FB-9CFA-EDE9F363CABF@mpi-bpc.mpg.de>
	 <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAK6E8=dcG3mw8r4FXt62G-0uoRNa9tcyQL3DS62MYe8F=9R6Nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44623 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758204Ab1LNWbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 17:31:53 -0500
Received: by wgbdr13 with SMTP id dr13so2561078wgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 14:31:52 -0800 (PST)
In-Reply-To: <CAK6E8=dcG3mw8r4FXt62G-0uoRNa9tcyQL3DS62MYe8F=9R6Nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 11:00 -0800, Yuchung Cheng a =C3=
=A9crit :
> >
> I use tcptrace to check the time sequence and I am puzzled:
> I see a lot of OOO packets too but how can this happen at a sender-si=
de trace?
> unless the trace is taken close to but not exactly at the sender.
> I expect on seeing in-sequence packets but a lots of SACKs plus some
> spurious retransmists.

I understood the trace was a receiver-side one (a linux machine if I am
not mistaken, while the sender is AIX powered)

(Looking at timings of ACKS, coming a few us after corresponding data
packet arrival)
