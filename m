From: Alejandro Riveira =?UTF-8?B?RmVybsOhbmRleg==?=
	<ariveira@gmail.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 15:43:26 +0200
Message-ID: <20080526154326.1fe44214@Varda>
References: <482C7E53.3050300@hp.com>
	<482C8184.2030906@garzik.org>
	<482C8550.5000909@intel.com>
	<482C8D4D.3040702@garzik.org>
	<20080516132107.GA11304@csclub.uwaterloo.ca>
	<20080516161029.44ded734@core>
	<20080516173610.GA27126@csclub.uwaterloo.ca>
	<20080516191125.46f59ad6@core>
	<a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com>
	<1211728189.5913.71.camel@andromache>
	<20080525232712.GF5970@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Glen Turner <gdt@gdt.id.au>,
	Chris Peterson <cpeterso@cpeterso.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Theodore Tso <tytso@MIT.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:5675 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267AbYEZNnh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 09:43:37 -0400
Received: by ug-out-1314.google.com with SMTP id h2so414260ugf.16
        for <netdev@vger.kernel.org>; Mon, 26 May 2008 06:43:35 -0700 (PDT)
In-Reply-To: <20080525232712.GF5970@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Sun, 25 May 2008 19:27:12 -0400
Theodore Tso <tytso@MIT.EDU> escribi=C3=B3:

> On Mon, May 26, 2008 at 12:39:49AM +0930, Glen Turner wrote:
> >=20
> > For example, /dev/random has run out. So the output of /dev/urandom
> > is now determined by previous values of /dev/random.  I then send i=
n
> > a stack of network packets at regular intervals. So the output of
> > /dev/urandom is now greatly determined by those packets.  My search
> > space for the resulting key is small since /dev/urandom appears to
> > be random, but in fact is periodic.
>=20
> That's not how it works.  Basically, as long as there is *some*
> entropy in the system, even from the /var/lib/random-seed, or from
> keyboard interrupts, or from mouse interrupts, which is unknown to th=
e
> attacker, in the worse case /dev/urandom will be no worse than a
> cryptographic random number generator.
>=20
 [ ... ]=20
=20
 Just a shot in the dark... would hw sensors (raw data) chips be a good=
 source
 of entropy for /dev/random ??=20

> 		      	     	     	- Ted
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
