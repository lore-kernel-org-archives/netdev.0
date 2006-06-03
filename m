From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Sat, 3 Jun 2006 10:45:08 +0200
Message-ID: <200606031045.08763.stefan@loplof.de>
References: <200605251716.00742.IvDoorn@gmail.com> <200605312005.31067.IvDoorn@gmail.com> <200606021630.34544.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from natipslore.rzone.de ([81.169.145.179]:13011 "EHLO
	natipslore.rzone.de") by vger.kernel.org with ESMTP
	id S1750772AbWFCIov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 04:44:51 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200606021630.34544.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag 02 Juni 2006 16:30 schrieb Ivo van Doorn:

> > Or actually, I don't think the radiobtn/ won't be actually needed as
> > prefix. The name passed to the radiobtn driver by the driver should be
> > sufficient.
>
> Updated version,
>
> Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

I don't like the patch in it's current form. Many notebooks have a number of 
additional keys that need to be queried/polled using the same interface, but 
just one button is to control the radio, the rest are multimedia keys that 
just need to be forwarded to userspace. Or maybe a bluetooth key.

Some systems require suspend/resume support, others remember state of the 
wireless button automatically. For a perfect example, look at 
drivers/input/misc/wistron_btns.c.

So you should create an "extra laptop buttons" interface. Though it may be 
hard to assure that this generalization layer between input system and 
hardware is still a win for the driver developer.

Stefan
