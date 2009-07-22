From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 22 Jul 2009 10:11:02 +0100
Message-ID: <20090722101102.4aba96bd@lxorguk.ukuu.org.uk>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	<1248184373.6558.15.camel@localhost.localdomain>
	<200907221137.07005.remi.denis-courmont@nokia.com>
	<200907221041.51995.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "=?ISO-8859-14?B?UultaQ==?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	ext Marcel Holtmann <marcel@holtmann.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:51284 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750922AbZGVJLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 05:11:19 -0400
In-Reply-To: <200907221041.51995.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The AT stuff is really problematic. Look at the hoops ISDN and software
> modem drivers go through to emulate AT commands. I know even of a CDC-ACM
> modem which can't deal with AT commands inline (that's within spec).
> It seems to me we should have a modem API in kernel.

For devices which don't deal in AT commands probably but for devices
whose firmware provides an AT command interface over serial I would
disagree.
