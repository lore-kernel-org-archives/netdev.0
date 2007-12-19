From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 18:58:57 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
 <Pine.LNX.4.64.0712181818360.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712181009pf954f43mcb63ea4dab638458@mail.gmail.com>
 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
 <4768123A.7040603@cosmosbay.com>  <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
  <47682F8C.20205@cosmosbay.com>  <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
  <47694FCC.1020507@cosmosbay.com> <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33324 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbXLSR66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 12:58:58 -0500
In-Reply-To: <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 19 2007 12:43, James Nichols wrote:
>On 12/19/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
>> James Nichols a =C3=A9crit :
>> >> So you see outgoing SYN packets, but no SYN replies coming from t=
he remote
>> >> peer ?  (you mention ACKS, but the first packet received from the=
 remote
>> >>  peer should be a SYN+ACK),
>> >
>> > Right, I meant to say SYN+ACK.  I don't see them coming back.
>>
>> So... Really unlikely a linux problem, but ...
>
>I don't know how you can be so sure.  Turning tcp_sack off instantly
>resovles the problem and all connections are succesful.  I can't
>imagine even the most far-fetched scenario where a router or every
>single remote endpoints would suddenly stop causing the problem just
>by removing a single TCP option.

The router could be sooo crappy that it drops all packets from
TCP streams that have SACK enabled and the client has opened
200+ SACK connections previously... something like that?

