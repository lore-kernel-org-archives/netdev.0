From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 08:45:33 +0100
Message-ID: <1322552733.2970.78.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	  <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	 <1322550138.2970.70.camel@edumazet-laptop> <4ED4885F.8060309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43056 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab1K2Hpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 02:45:42 -0500
Received: by bkas6 with SMTP id s6so126848bka.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 23:45:38 -0800 (PST)
In-Reply-To: <4ED4885F.8060309@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 23:23 -0800, John Fastabend a =C3=A9cr=
it :

> I wonder if we should consider enabling TSO/GSO per queue or per traf=
fic
> class on devices that support this. At least in devices that support
> multiple traffic classes it seems to be a common usage case to put bu=
lk
> storage traffic (iSCSI) on a traffic class and low latency traffic on=
 a
> separate traffic class, VoIP for example.
>=20

It all depends on how device itself is doing its mux from queues to
ethernet wire. If queue 0 starts transmit of one 64KB 'super packet',
will queue 1 be able to insert a litle frame between the frames of queu=
e
0 ?
