From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] f_phonet: avoid pskb_pull(), fix OOPS with
 CONFIG_HIGHMEM
Date: Mon, 28 Feb 2011 12:38:44 -0800 (PST)
Message-ID: <20110228.123844.70195701.davem@davemloft.net>
References: <linux-usb@vger.kernel.org>
	<1298465493-3787-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753092Ab1B1UiH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 15:38:07 -0500
In-Reply-To: <1298465493-3787-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 23 Feb 2011 14:51:33 +0200

> This is similar to what we already do in cdc-phonet.c in the same
> situation. pskb_pull() refuses to work with HIGHMEM, even if it is
> known that the socket buffer is entirely in "low" memory.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks.
