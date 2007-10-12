From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] [TCP]: Fix mark_head_lost to ignore R-bit when
 trying to mark L
Date: Thu, 11 Oct 2007 17:33:22 -0700 (PDT)
Message-ID: <20071011.173322.56803094.davem@davemloft.net>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbXJLAdU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 20:33:20 -0400
In-Reply-To: <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 11 Oct 2007 14:41:02 +0300

> This condition (plain R) can arise at least in recovery that
> is triggered after tcp_undo_loss. There isn't any reason why
> they should not be marked as lost, not marking makes in_flight
> estimator to return too large values.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Nice observation, applied, thanks Ilpo.
