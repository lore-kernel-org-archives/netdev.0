From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 20:26:55 +0200
Message-ID: <1309890415.2545.13.camel@edumazet-laptop>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	 <1309846875.2720.43.camel@edumazet-laptop> <4E12B5A6.2020802@inliniac.net>
	 <1309849214.2720.45.camel@edumazet-laptop>
	 <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
	 <1309882577.2271.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E133A09.8030907@inliniac.net>
	 <1309882999.2271.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E1346B7.4000105@inliniac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Victor Julien <victor@inliniac.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59538 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab1GES1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:27:00 -0400
Received: by wyg8 with SMTP id 8so4184495wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 11:26:59 -0700 (PDT)
In-Reply-To: <4E1346B7.4000105@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 19:15 +0200, Victor Julien a =C3=A9crit=
 :
> On 07/05/2011 06:23 PM, Eric Dumazet wrote:
> > Le mardi 05 juillet 2011 =C3=A0 18:21 +0200, Victor Julien a =C3=A9=
crit :
> >> On 07/05/2011 06:16 PM, Eric Dumazet wrote:
> >>> Remember, goal is that _all_ packets of a given flow end in same =
queue.
> >>>
> >>
> >> What about a hashing scheme based on just the ip addresses? Would =
make
> >> rxhash useless for this purpose, but would be a lot simpler overal=
l maybe...
> >>
> >=20
> > What about loads where a single IP address is used ?
>=20
> How would that be a problem?

Say I want my program able to process 2.000.000 packets per second on m=
y
64 cpu machine, but one cpu is only able to process 100.000 pps.

All these packets are coming from IP1, and go to IP2, but thousand of
different flows are in flight.

We need hash function taking into account source port and destination
port.



