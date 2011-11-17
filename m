From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 15:33:57 -0200
Message-ID: <20111117153357.7bc5a4d4@asterix.rh>
References: <4EC2CA52.6020104@icdsoft.com>
	<1321391355.2602.0.camel@edumazet-laptop>
	<4EC439F2.3080809@icdsoft.com>
	<20111116223330.08de9e52@asterix.rh>
	<4EC4C160.6010804@icdsoft.com>
	<20111117111145.252924f5@asterix.rh>
	<1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117133724.59684d28@asterix.rh>
	<1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117144038.61b0525b@asterix.rh>
	<1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117150145.25e01a75@asterix.rh>
	<1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706Ab1KQReQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 12:34:16 -0500
In-Reply-To: <1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 18:18:22 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 17 novembre 2011 =C3=A0 15:01 -0200, Flavio Leitner a =C3=A9=
crit :
>=20
> > Right, so the loop trying different oif and saddr isn't working at
> > all because __ip_route_output_key() will create a route in the firs=
t
> > attempt.  Looks like you're right and we need the 'create' paramete=
r
> > in __ip_route_output_key().
>=20
> And we have to loop on all possible keys combinations.
>=20
> (like code before David commit (f39925dbde77 ipv4: Cache learned
> redirect information in inetpeer.) : it had a goto do_next;

That is correct. I realize that now.

> I am preparing a patch.
thank you.

fbl
