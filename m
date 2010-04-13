From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resubmission] drivers/net/usb: Add new driver ipheth
Date: Tue, 13 Apr 2010 01:15:40 -0700 (PDT)
Message-ID: <20100413.011540.115903049.davem@davemloft.net>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
	<1270678281-20750-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	gregkh@suse.de, jonas.sjoquist@ericsson.com,
	steve.glendinning@smsc.com, torgny.johansson@gmail.com,
	dbrownell@users.sourceforge.net, omar.oberthur@gmail.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: agimenez@sysvalve.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50439
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751420Ab0DMIPh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 04:15:37 -0400
In-Reply-To: <1270678281-20750-1-git-send-email-agimenez@sysvalve.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: L. Alberto Gim=E9nez <agimenez@sysvalve.es>
Date: Thu,  8 Apr 2010 00:11:20 +0200

> From: dborca@yahoo.com
>=20
> Add new driver to use tethering with an iPhone device. After initial =
submission,
> apply fixes to fit the new driver into the kernel standards.
>=20
> There are still a couple of minor (almost cosmetic-level) issues, but=
 the driver
> is fully functional right now.
>=20
> Signed-off-by: L. Alberto Gim=E9nez <agimenez@sysvalve.es>

I can't apply this.

Unless you add a rule to drivers/net/Makefile, the build won't
actually get to your driver unless one of the other USB networking
devices are configured.

Please fix this up and resubmit.
