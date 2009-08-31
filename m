From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Revert Backoff [v3]: Rename skb to icmp_skb in
 tcp_v4_err()
Date: Mon, 31 Aug 2009 06:34:35 -0700 (PDT)
Message-ID: <20090831.063435.190660445.davem@davemloft.net>
References: <4A950B7B.4010601@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0908311538050.29341@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: damian@tvk.rwth-aachen.de, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44154
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752797AbZHaNeV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2009 09:34:21 -0400
In-Reply-To: <alpine.DEB.2.00.0908311538050.29341@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 31 Aug 2009 16:22:58 +0300 (EEST)

> Not that related to the purpose of this patch but still worth to
> mention now that we are in the context... ...I wonder if this should
> be pskb_may_pull instead of direct compare here regardless of this
> change?

ICMP layer that invokes this code makes sure enough headers
are in the linear area already.

> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for reviewing.
