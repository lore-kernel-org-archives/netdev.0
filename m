From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 15:19:41 +0100
Message-ID: <20090724151941.40dba19d@lxorguk.ukuu.org.uk>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	<200907241431.08858.oliver@neukum.org>
	<20090724134805.0d9496be@lxorguk.ukuu.org.uk>
	<200907241612.41871.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "=?ISO-8859-14?B?UultaQ==?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:60162 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751827AbZGXOSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 10:18:54 -0400
In-Reply-To: <200907241612.41871.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Jul 2009 16:12:41 +0200
Oliver Neukum <oliver@neukum.org> wrote:

> Am Freitag, 24. Juli 2009 14:48:05 schrieb Alan Cox:
> > > No, I was thinking of having two full devices, a data channel and a
> > > control channel for devices that really talk AT commands natively.
> >
> > If the hardware does it great, however for things like a 3G modem you
> > have the problem that the PPP is over the AT command channel which may
> > itself be multiplexed. And the muxing in question is *ugly* - sort of
> > HDLC and LAP-B done wrong.
> 
> Well, yes, but we would really like a separate control channel, so we
> can query parameters like signal strength, while we do PPP over the data
> channel.

Thats the notion of the AT mux stuff - you get multiple AT channels and
you can stuff PPP down one of them. It's still butt ugly.
