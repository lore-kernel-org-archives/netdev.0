From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/3] [TCP]: Reordered ACK's (old) SACKs not
 included to discarded MIB
Date: Tue, 25 Sep 2007 22:47:11 -0700 (PDT)
Message-ID: <20070925.224711.26514452.davem@davemloft.net>
References: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11906246484144-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50312
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751986AbXIZFrL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 01:47:11 -0400
In-Reply-To: <11906246484144-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Sep 2007 12:04:07 +0300

> In case of ACK reordering, the SACK block might be valid in it's
> time but is already obsoleted since we've received another kind
> of confirmation about arrival of the segments through snd_una
> advancement of an earlier packet.
>=20
> I didn't bother to build distinguishing of valid and invalid
> SACK blocks but simply made reordered SACK blocks that are too
> old always not counted regardless of their "real" validity which
> could be determined by using the ack field of the reordered
> packet (won't be significant IMHO).
>=20
> DSACKs can very well be considered useful even in this situation,
> so won't do any of this for them.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

This looks fine to me, applied.

If the skipped case is interesting we can add another MIB
stat for it :-)
