From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: QoS hot changes changes (tc)
Date: Sat, 27 Jun 2009 23:42:26 +0200
Message-ID: <4A469242.4070000@gmail.com>
References: <3f847c820906260619g238b6a17ub17af3f27da83ef5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org >> Linux Netdev List"
	<netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?= <rauhersu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:43076 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbZF0Vmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2009 17:42:52 -0400
Received: by fxm18 with SMTP id 18so315733fxm.37
        for <netdev@vger.kernel.org>; Sat, 27 Jun 2009 14:42:54 -0700 (PDT)
In-Reply-To: <3f847c820906260619g238b6a17ub17af3f27da83ef5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ra=FAl Hern=E1ndez wrote, On 06/26/2009 03:19 PM:

> Hi there,
>=20
> I am trying to characterize the situation in which we perform a chang=
e
> in the shaping done by the Linux kernel (tc+qdisc), specifically when
> modifying the bandwidth as a hot change while shaping with a previous
> bw value. The system I am describing performs shaping per stream
> (uplink and/or dowinlink or total), just marking the TOS of the ip
> packet and provisioning the kernel via 'tc' to shape the packets.
>=20
> My question is whether someone has tried to modify bw parameters, ie:
> move from 90 to 45 kb/s while the queues are already being populated
> with trafffic .Do not know if the shaper algorithm is able to adjust
> the bw without service disruption/experiment transitory behavior as I
> guess the algorithm must have some kind of feedback which depends of
> the bytes already shaped and the value of the bw itself (ie: leaky
> bucket).
>=20
> Any experience with this kind of changes :-) ? Thx !

No experience in measuring the effects of such changes, but looking
into code shows it depends on a shaper algorithm: tbf seems to reset
the queue, htb doesn't.

Jarek P.
