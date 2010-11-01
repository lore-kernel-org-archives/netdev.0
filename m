From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: fix usb_autopm_get_interface failure(v1)
Date: Mon, 01 Nov 2010 08:08:25 -0700 (PDT)
Message-ID: <20101101.080825.193699846.davem@davemloft.net>
References: <1288620349-9769-1-git-send-email-tom.leiming@gmail.com>
	<AANLkTim_NRFV0ELzpOE6K539Wfxsw8j1eW-3TXLCrgOZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tom.leiming@gmail.com, netdev@vger.kernel.org, oliver@neukum.org,
	dbrownell@users.sourceforge.net, gregkh@suse.de,
	ben@decadent.org.uk, joe@perches.com, stable@kernel.org
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753471Ab0KAPIC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 11:08:02 -0400
In-Reply-To: <AANLkTim_NRFV0ELzpOE6K539Wfxsw8j1eW-3TXLCrgOZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Mon, 1 Nov 2010 17:04:35 +0200

>> + =A0 =A0 =A0 /*usbnet already took usb runtime pm, so have to enabl=
e the feature
>> + =A0 =A0 =A0 * for usb interface, otherwise usb_autopm_get_interfac=
e may return
>> + =A0 =A0 =A0 * failure if USB_SUSPEND(RUNTIME_PM) is enabled.
>> + =A0 =A0 =A0 * */
> Just minor: multiline comments doesn't follow the required style.

There were also spaces before tabs at the beginning of each
line.

I fixed all of this up when applying the patch.
