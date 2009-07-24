From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 14:31:08 +0200
Message-ID: <200907241431.08858.oliver@neukum.org>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <200907241401.20262.oliver@neukum.org> <200907241514.18871.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:53126 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbZGXMao convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 08:30:44 -0400
In-Reply-To: <200907241514.18871.remi.denis-courmont@nokia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 24. Juli 2009 14:14:17 schrieb R=E9mi Denis-Courmont:
> On Friday 24 July 2009 15:01:19 ext Oliver Neukum wrote:
> > Am Mittwoch, 22. Juli 2009 11:15:34 schrieb Marcel Holtmann:
> > > > > The AT stuff is really problematic. Look at the hoops ISDN an=
d
> > > > > software modem drivers go through to emulate AT commands. I k=
now
> > > > > even of a CDC-ACM modem which can't deal with AT commands inl=
ine
> > > > > (that's within spec). It seems to me we should have a modem A=
PI in
> > > > > kernel.
> > > >
> > > > For devices which don't deal in AT commands probably but for de=
vices
> > > > whose firmware provides an AT command interface over serial I w=
ould
> > > > disagree.
> > >
> > > I fully agree here. Even if you think you get AT commands under
> > > control, you really won't in the end. That standard is so wildly
> > > mis-interpreted that it is not even funny anymore.
> >
> > For these devices we could at least separate the data channel from =
the
> > control channel.
>
> "These" as in AT devices? You want a line discipline to multiplex AT
> commands inspite of PPP? I wonder if that'd work.

No, I was thinking of having two full devices, a data channel and a con=
trol
channel for devices that really talk AT commands natively.

	Regards
		Oliver

