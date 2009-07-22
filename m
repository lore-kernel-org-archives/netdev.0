From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 22 Jul 2009 11:15:34 +0200
Message-ID: <1248254134.28545.111.camel@violet>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	 <1248184373.6558.15.camel@localhost.localdomain>
	 <200907221137.07005.remi.denis-courmont@nokia.com>
	 <200907221041.51995.oliver@neukum.org>
	 <20090722101102.4aba96bd@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37491 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbZGVJQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 05:16:14 -0400
In-Reply-To: <20090722101102.4aba96bd@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,

> > The AT stuff is really problematic. Look at the hoops ISDN and software
> > modem drivers go through to emulate AT commands. I know even of a CDC-ACM
> > modem which can't deal with AT commands inline (that's within spec).
> > It seems to me we should have a modem API in kernel.
> 
> For devices which don't deal in AT commands probably but for devices
> whose firmware provides an AT command interface over serial I would
> disagree.

I fully agree here. Even if you think you get AT commands under control,
you really won't in the end. That standard is so wildly mis-interpreted
that it is not even funny anymore.

Regards

Marcel


