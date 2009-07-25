From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Sat, 25 Jul 2009 13:07:33 +0200
Message-ID: <1248520053.28545.156.camel@violet>
References: <4A6AD807.6060706@hartkopp.net>
	 <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49136 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbZGYLI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 07:08:26 -0400
In-Reply-To: <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,

> > this morning i got a NULL pointer dereference in tty_register_device() that
> > looked similar to the one, i posted here on 03-jun-2009:
> > 
> > http://marc.info/?l=linux-bluetooth&m=124404919324542&w=2
> > 
> > As the boot sequence stopped after this point, i was only able to take a
> > picture of it - see attached jpg.
> > 
> > I was able to shut down the system gracefully by pressing the power button.
> > 
> > The problem emerges really seldom.
> > 
> > Any idea?
> 
> tty_register_device appears to have been called with a NULL pointer. Not
> sure why however.

if that is the pointer for the struct device, then that used to be fine
in the past. Not all RFCOMM device have a parent when they are created.

Regards

Marcel


