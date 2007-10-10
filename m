From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] [TCP]: Limit processing lost_retrans loop to
 work-to-do cases
Date: Wed, 10 Oct 2007 02:44:03 -0700 (PDT)
Message-ID: <20071010.024403.116354578.davem@davemloft.net>
References: <11919324023846-git-send-email-ilpo.jarvinen@helsinki.fi>
	<119193240269-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11919324033627-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43892
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753968AbXJJJoA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 05:44:00 -0400
In-Reply-To: <11919324033627-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue,  9 Oct 2007 15:20:02 +0300

> This addition of lost_retrans_low to tcp_sock might be
> unnecessary, it's not clear how often lost_retrans worker is
> executed when there wasn't work to do.
>=20
> Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I wanted to apply this, but it doesn't go cleanly on top of
net-2.6.24, can you respin this patch for me?

Thanks!
