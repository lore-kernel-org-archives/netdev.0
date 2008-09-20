From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/15] tcp: convert retransmit_cnt_hint to
 seqno
Date: Sat, 20 Sep 2008 13:36:48 -0700 (PDT)
Message-ID: <20080920.133648.12203243.davem@davemloft.net>
References: <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
	<Pine.LNX.4.64.0809202055270.6906@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbYITUhA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2008 16:37:00 -0400
In-Reply-To: <Pine.LNX.4.64.0809202055270.6906@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 20 Sep 2008 20:59:29 +0300 (EEST)

> On Sat, 20 Sep 2008, Ilpo J=E4rvinen wrote:
>=20
> > +
> > +	if (!tp->lost_out ||
>=20
> Never-mind about this patchset, this is a broken to begin with in cer=
tain=20
> cases where we weren't that lucky (once a again the right after posti=
ng I=20
> notice a problem :-)). The problem is basically that we do increments=
 for=20
> lost_out in many place before calling the verify. I'll fix it and rep=
ost=20
> once I get that done.

Ok, I'll drop these patches :)
