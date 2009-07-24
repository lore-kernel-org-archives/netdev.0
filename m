From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 15:14:17 +0300
Message-ID: <200907241514.18871.remi.denis-courmont@nokia.com>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <1248254134.28545.111.camel@violet> <200907241401.20262.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: ext Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:35482 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbZGXMMj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 08:12:39 -0400
In-Reply-To: <200907241401.20262.oliver@neukum.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 24 July 2009 15:01:19 ext Oliver Neukum wrote:
> Am Mittwoch, 22. Juli 2009 11:15:34 schrieb Marcel Holtmann:
> > > > The AT stuff is really problematic. Look at the hoops ISDN and
> > > > software modem drivers go through to emulate AT commands. I kno=
w even
> > > > of a CDC-ACM modem which can't deal with AT commands inline (th=
at's
> > > > within spec). It seems to me we should have a modem API in kern=
el.
> > >
> > > For devices which don't deal in AT commands probably but for devi=
ces
> > > whose firmware provides an AT command interface over serial I wou=
ld
> > > disagree.
> >
> > I fully agree here. Even if you think you get AT commands under con=
trol,
> > you really won't in the end. That standard is so wildly mis-interpr=
eted
> > that it is not even funny anymore.
>
> For these devices we could at least separate the data channel from th=
e
> control channel.

"These" as in AT devices? You want a line discipline to multiplex AT co=
mmands=20
inspite of PPP? I wonder if that'd work.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

