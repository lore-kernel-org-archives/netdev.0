From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 19:28:27 +0100
Message-ID: <1324664907.2915.5.camel@edumazet-laptop>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	 <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	 <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41281 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab1LWS2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 13:28:31 -0500
Received: by wgbdr13 with SMTP id dr13so17819240wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 10:28:30 -0800 (PST)
In-Reply-To: <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 18:54 +0100, Dave Taht a =C3=A9=
crit :

> Are there any place where all 48 bytes of cb are used?
>=20

Yes, but on in qdisc layer.

struct tcp_skb_cb is known to be 44 bytes (when IPv6 is enabled)

In qdisc layer, we use a small part of it, for the moment.

> I wouldn't mind if 'time_to_send' became a separate skb field
> for a more generic 'time_in_queue'...
>=20

This wont happen.

As I posted in an earlier patch, this can be added in "struct
qdisc_skb_cb"
