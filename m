From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [TCP]: Add bytes_acked (ABC) clearing to FRTO too
Date: Thu, 11 Oct 2007 17:32:40 -0700 (PDT)
Message-ID: <20071011.173240.11376079.davem@davemloft.net>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53330
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753253AbXJLAck convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 20:32:40 -0400
In-Reply-To: <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 11 Oct 2007 14:41:01 +0300

> I was reading tcp_enter_loss while looking for Cedric's bug and
> noticed bytes_acked adjustment is missing from FRTO side.
>=20
> Since bytes_acked will only be used in tcp_cong_avoid, I think
> it's safe to assume RTO would be spurious. During FRTO cwnd
> will be not controlled by tcp_cong_avoid and if FRTO calls for
> conventional recovery, cwnd is adjusted and the result of wrong
> assumption is cleared from bytes_acked. If RTO was in fact
> spurious, we did normal ABC already and can continue without
> any additional adjustments.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
