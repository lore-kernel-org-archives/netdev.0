From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: fix accounting race between gprs_writeable()
 and gprs_xmit()
Date: Tue, 02 Jun 2009 00:17:56 -0700 (PDT)
Message-ID: <20090602.001756.104174692.davem@davemloft.net>
References: <1243852516-16597-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760166AbZFBHR4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 03:17:56 -0400
In-Reply-To: <1243852516-16597-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Mon,  1 Jun 2009 13:35:16 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> In the unlikely event that gprs_writeable() and gprs_xmit() check for
> writeability at the same, we could stop the device queue forever.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied to net-next-2.6
