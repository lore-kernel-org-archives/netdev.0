From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Mon, 26 Jul 2010 11:13:23 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1007261106350.1550-100000@iolanthe.rowland.org>
References: <AANLkTin_pduYCHVv_q4DSfSoQ7o4kFo43X8t1rXJ+7fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>
To: Elly Jones <ellyjones@google.com>,
	Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:49047 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753614Ab0GZPNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 11:13:24 -0400
In-Reply-To: <AANLkTin_pduYCHVv_q4DSfSoQ7o4kFo43X8t1rXJ+7fa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Jul 2010, Elly Jones wrote:

> > This isn't right. =A0The problem should be fixed some other way. =A0=
Under
> > what circumstances are URBs submitted incorrectly?
>=20
> When the device is autosuspended. What is the proper thing for a
> device to do here?

=46rom looking at the code, it appears that the EVENT_DEV_ASLEEP flag
should be tested in usbnet_bh() the way it is in rx_submit().  But I'm
not an expert on usbnet; we should ask someone who is, like Oliver.

Alan Stern

