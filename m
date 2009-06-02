From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] f_phonet: dev_kfree_skb instead of
 dev_kfree_skb_any in TX callback
Date: Tue, 02 Jun 2009 00:18:05 -0700 (PDT)
Message-ID: <20090602.001805.46146029.davem@davemloft.net>
References: <1243855137-20149-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644AbZFBHSF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 03:18:05 -0400
In-Reply-To: <1243855137-20149-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Mon,  1 Jun 2009 14:18:55 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Network device TX is never run in IRQ context, and skb is freed outsi=
de
> of the IRQ-disabling spin lock. So checking for IRQ was a waste of ti=
me
> here.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Signed-off-by: Felipe Balbi <felipe.balbi@nokia.com>

Applied to net-next-2.6
