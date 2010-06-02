From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/fec: fix pm to survive to suspend/resume
Date: Wed, 02 Jun 2010 06:13:44 -0700 (PDT)
Message-ID: <20100602.061344.129778393.davem@davemloft.net>
References: <20100529.001534.57459102.davem@davemloft.net>
	<1275163490-13027-1-git-send-email-eric@eukrea.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	sshtylyov@mvista.com, linux-arm-kernel@lists.infradead.org,
	fabioestevam@yahoo.com
To: eric@eukrea.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753207Ab0FBNNe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 09:13:34 -0400
In-Reply-To: <1275163490-13027-1-git-send-email-eric@eukrea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric B=E9nard <eric@eukrea.com>
Date: Sat, 29 May 2010 22:04:50 +0200

> * in the actual driver, calling fec_stop and fec_enet_init doesn't
> allow to have a working network interface at resume (where a
> ifconfig down and up is required to recover the interface)
> * by using fec_enet_close and fec_enet_open, this patch solves this
> problem and handle the case where the link changed between suspend
> and resume
> * this patch also disable clock at suspend and reenable it at resume
>=20
> Signed-off-by: Eric B=E9nard <eric@eukrea.com>

Applied, thanks.
