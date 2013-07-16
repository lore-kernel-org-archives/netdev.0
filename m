From: Ranjan Maitra <maitra.mbox.ignored@inbox.com>
Subject: any plans to include dm9620 to net-next?
Date: Tue, 16 Jul 2013 16:00:35 -0500
Message-ID: <20130716160035.1c793c6992f50865c8b7d8db@inbox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wm44.inbox.com ([64.135.83.44]:4949 "HELO WM44.inbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933606Ab3GPVKn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 17:10:43 -0400
Received: from inbox.com (127.0.0.1:25)
	by inbox.com with [InBox.Com SMTP Server]
	id <1307161300040.WM44> for <netdev@vger.kernel.org> from <maitra.mbox.ignored@inbox.com>;
	Tue, 16 Jul 2013 13:00:36 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been suggested to e-mail this list. My Dell XPS 13 is one of
those without an ethernet outlet (for want of a better term). So I
purchased a Keydex UG-ND1118-SV USB Lan Adapter and  hooked it on, but
it does not appear to be recognized (Fedora 19). Looking around it
turns out that it is missing a driver.
http://marc.info/?l=3Dlinux-netdev&m=3D137173085617601

This driver is OSS and GPL'd so I wonder when this will show up on
net-next. Apparently, the 3.10 linux kernel has some support for it:

$ modinfo dm9620
filename:
/lib/modules/3.10.0-707.fc19.x86_64/kernel/drivers/net/usb/dm9620.ko
license:        GPL
description:    Davicom DM9620 USB 2.0 ethernet devices
author:         Peter Korsgaard <jacmet@sunsite.dk>
alias:          usb:v0A46p1269d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v0A46p0269d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v0A46p9622d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v0A46p9621d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v0A46p9620d*dc*dsc*dp*ic*isc*ip*in*
depends:        usbnet,mii
vermagic:       3.10.0-707.fc19.x86_64 SMP mod_unload

The driver can be compiled against these.

Any ideas when/whether this will be supported in the kernel?

My apologies at my lack of clarity. Thank you very much, however, for
your time!

Best wishes,
Ranjan

____________________________________________________________
GET FREE SMILEYS FOR YOUR IM & EMAIL - Learn more at http://www.inbox.c=
om/smileys
Works with AIM=C2=AE, MSN=C2=AE Messenger, Yahoo!=C2=AE Messenger, ICQ=C2=
=AE, Google Talk=E2=84=A2 and most webmails
