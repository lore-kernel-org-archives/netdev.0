From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] [TCP]: Make fackets_out accurate
Date: Thu, 20 Sep 2007 11:30:04 -0700 (PDT)
Message-ID: <20070920.113004.18709954.davem@davemloft.net>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57162
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754225AbXITSaE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 14:30:04 -0400
In-Reply-To: <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Sep 2007 15:17:45 +0300

> Substraction for fackets_out is unconditional when snd_una
> advances, thus there's no need to do it inside the loop. Just
> make sure correct bounds are honored.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
