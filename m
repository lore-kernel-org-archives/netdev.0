From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [TCP]: Re-place highest_sack check to a more
 robust position
Date: Tue, 25 Sep 2007 22:44:29 -0700 (PDT)
Message-ID: <20070925.224429.124284210.davem@davemloft.net>
References: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50309
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbXIZFo3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 01:44:29 -0400
In-Reply-To: <11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Sep 2007 12:04:06 +0300

> I previously added checking to position that is rather poor as
> state has already been adjusted quite a bit. Re-placing it above
> all state changes should be more robust though the return should
> never ever get executed regardless of its place :-).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6.24, thanks Ilpo.
