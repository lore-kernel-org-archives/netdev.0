From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 18:59:17 +0200
Message-ID: <200907241859.17883.oliver@neukum.org>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <200907241612.41871.oliver@neukum.org> <20090724151941.40dba19d@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:55474 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbZGXSoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 14:44:10 -0400
In-Reply-To: <20090724151941.40dba19d@lxorguk.ukuu.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 24. Juli 2009 16:19:41 schrieb Alan Cox:
> On Fri, 24 Jul 2009 16:12:41 +0200
>
> Oliver Neukum <oliver@neukum.org> wrote:
> > Am Freitag, 24. Juli 2009 14:48:05 schrieb Alan Cox:
> > > > No, I was thinking of having two full devices, a data channel and a
> > > > control channel for devices that really talk AT commands natively.
> > >
> > > If the hardware does it great, however for things like a 3G modem you
> > > have the problem that the PPP is over the AT command channel which may
> > > itself be multiplexed. And the muxing in question is *ugly* - sort of
> > > HDLC and LAP-B done wrong.
> >
> > Well, yes, but we would really like a separate control channel, so we
> > can query parameters like signal strength, while we do PPP over the data
> > channel.
>
> Thats the notion of the AT mux stuff - you get multiple AT channels and
> you can stuff PPP down one of them. It's still butt ugly.

That is a problem. But is it so ugly that we'd forgo the added functionality
rather than implement it in the kernel?
If not, I maintain that we should not maintain several different control channel
interfaces, like some devices use cdc-wdm, others a ttyUSB and the AT mux
stuff shall use yet a different method.

	Regards
		Oliver

