From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 4/7] can/at91: don't check platform_get_irq's return value
 against zero
Date: Thu, 17 Dec 2009 08:17:31 +0100
Message-ID: <4B29DB0B.1060109@grandegger.com>
References: <1260979809-24811-1-git-send-email-u.kleine-koenig@pengutronix.de>	<1260979809-24811-2-git-send-email-u.kleine-koenig@pengutronix.de>	<1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de>	<1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de>	<4B290A57.3010705@grandegger.com>	<20091216170802.GA26325@pengutronix.de> <20091216174749.277761fe@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, linux-kernel@vger.kernel.org,
	David Vrabel <dvrabel@arcom.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:42387 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758900AbZLQHS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 02:18:27 -0500
In-Reply-To: <20091216174749.277761fe@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
>> +       if (!res || irq <= (int)NO_IRQ) {
>>
>> but this looks too ugly.  (IMHO using NO_IRQ is already ugly.)
> 
> No IRQ was a private variable for the drivers/ide stack internally and
> only present in any form on a few odd platforms where it got "borrowed"
> and hasn't yet been eliminated
> 
> The absence of an IRQ is zero. A bus IRQ of zero is remapped by the OS.

OK, I was remembering some old issues with NO_IRQ. Next time I will read
the commit message more carefully. Sorry for the noise.

Wolfgang.
