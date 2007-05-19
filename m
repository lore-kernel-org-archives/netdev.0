From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-2.6] [TCP] FRTO: Add missing ECN CWR sending
 to one of the responses
Date: Sat, 19 May 2007 13:56:32 -0700 (PDT)
Message-ID: <20070519.135632.126762760.davem@davemloft.net>
References: <Pine.LNX.4.64.0705181213360.28356@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33035
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760325AbXESU4h convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2007 16:56:37 -0400
In-Reply-To: <Pine.LNX.4.64.0705181213360.28356@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 18 May 2007 12:15:21 +0300 (EEST)

> The conservative spurious RTO response did not queue CWR even
> though the sending rate was lowered. Whenever reduction happens
> regardless of reason, CWR should be sent (forgetting to send it
> is not very fatal though).
>=20
> A better approach would be to queue CWR when one of the sending
> rate reducing responses (rate-halving one or this conservative
> response) is used already at RTO. Doing that would allow CWR to
> be sent along with the two new data segments that are sent
> during FRTO. However, it's a bit "racy" because userland could
> tune the response sysctl to a more aggressive one in between.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
