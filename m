From: David Miller <davem@davemloft.net>
Subject: Re: [resend] [PATCH] IPv4: Reset scope when changing address
Date: Tue, 26 Feb 2008 18:18:10 -0800 (PST)
Message-ID: <20080226.181810.240565409.davem@davemloft.net>
References: <87bq6hazvo.fsf@obelix.mork.no>
	<20080217.222245.132418529.davem@davemloft.net>
	<873arib4vd.fsf@obelix.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50287
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763428AbYB0CRZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 21:17:25 -0500
In-Reply-To: <873arib4vd.fsf@obelix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn_Mork <bjorn@mork.no>
Date: Sun, 24 Feb 2008 19:12:38 +0100

> We set the scope to RT_SCOPE_HOST if an IPv4 interface is configured
> with a loopback address (127/8).  The scope is never reset, and will
> remain set to RT_SCOPE_HOST after changing the address. This patch
> resets the scope if the address is changed again, to restore normal
> functionality.
>=20
> Signed-off-by: Bjorn Mork <bjorn@mork.no>

This patch looks fine, applied, thanks!
