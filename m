From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drivers/net/tile/: on-chip network drivers for the
 tile architecture
Date: Wed, 03 Nov 2010 18:50:22 +0100
Message-ID: <1288806622.2511.187.camel@edumazet-laptop>
References: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com>
	 <20101103125959.3231daa1@s6510>  <4CD19DCF.1040709@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57743 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab0KCRua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 13:50:30 -0400
In-Reply-To: <4CD19DCF.1040709@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 novembre 2010 =C3=A0 13:37 -0400, Chris Metcalf a =C3=A9=
crit :
> Stephen, thanks for your feedback!
>=20
> On 11/3/2010 12:59 PM, Stephen Hemminger wrote:
> > 1. MUST not use volatile, see volatile-considered-harmful.txt
>=20
> The "harmful" use of volatile is in trying to fake out SMP.  Believe =
me,
> with a 64-core architecture, we know our SMP guidelines. :-)  Our use=
 here
> is simply to force the compiler to issue a load, for the side-effect =
of
> populating the TLB, for example.
>=20
> However, your response does suggest that simply the syntactic use of
> "volatile" will cause a red flag for readers.  I'll move this to an i=
nline
> function in a header with a comment explaining what it's for, and use=
 the
> function instead.

Please read Documentation/volatile-considered-harmful.txt

Then if there is a problem, we can make change to the documentation, bu=
t
volatile use in new code is _strictly_ forbidden.

ACCESS_ONCE() is your friend, we might document it in
Documentation/volatile-considered-harmful.txt



