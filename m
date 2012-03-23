From: Oliver Neukum <oliver@neukum.org>
Subject: Re: Regression due to: net/usbnet: avoid recursive locking in usbnet_stop()
Date: Fri, 23 Mar 2012 08:21:51 +0100
Message-ID: <201203230821.51870.oliver@neukum.org>
References: <4F6BAE34.7010805@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Willy Tarreau <willy@meta-x.org>,
	Alan Stern <stern@rowland.harvard.edu>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:35129 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab2CWHVl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 03:21:41 -0400
In-Reply-To: <4F6BAE34.7010805@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 22. M=E4rz 2012, 23:56:52 schrieb Stephen Warren:
> It looks like commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d
> "net/usbnet: avoid recursive locking in usbnet_stop()" causes a probl=
em
> for me.
>=20
> When I reboot or shutdown, I see the error spew below at least 50% of
> the time. Reverting the above patch fixes this, at least for 10 reboo=
t
> attempts.

The patch "usbnet: increase URB reference count before usb_unlink_urb" =
has just been
applied. Could you test whether it fixes your proble?

	Regards
		Oliver
