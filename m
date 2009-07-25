From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Sat, 25 Jul 2009 11:50:11 +0100
Message-ID: <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk>
References: <4A6AD807.6060706@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:46420 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751568AbZGYKtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 06:49:06 -0400
In-Reply-To: <4A6AD807.6060706@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jul 2009 12:01:43 +0200
Oliver Hartkopp <oliver@hartkopp.net> wrote:

> Hello Alan and Marcel,
> 
> this morning i got a NULL pointer dereference in tty_register_device() that
> looked similar to the one, i posted here on 03-jun-2009:
> 
> http://marc.info/?l=linux-bluetooth&m=124404919324542&w=2
> 
> As the boot sequence stopped after this point, i was only able to take a
> picture of it - see attached jpg.
> 
> I was able to shut down the system gracefully by pressing the power button.
> 
> The problem emerges really seldom.
> 
> Any idea?

tty_register_device appears to have been called with a NULL pointer. Not
sure why however.
