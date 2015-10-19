From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [GIT PULL] ARCNET: features and fixes
Date: Mon, 19 Oct 2015 09:24:27 +0200
Message-ID: <20151019072427.GB23038@pengutronix.de>
References: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
 <20151018.201942.595687134692884924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:38516 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbbJSHYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 03:24:31 -0400
Content-Disposition: inline
In-Reply-To: <20151018.201942.595687134692884924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Oct 18, 2015 at 08:19:42PM -0700, David Miller wrote:
> From: Michael Grzeschik <m.grzeschik@pengutronix.de>
> Date: Fri, 16 Oct 2015 13:00:54 +0200
> 
> > This series includes some small fixes. The main changes are the correct
> > xceiver handling (enable/disable) of the com20020 cards. The driver now handles
> > link status change detection. The EAE PCI-ARCNET cards now make use of the
> > rotary encoded subdevice indexing and got support for led triggers on transmit
> > and reconnection events.
> 
> If you mix features and bug fixes, then it's ambiguous which tree these
> changes should go into.
> 
> If it's just fixes, then it's clearly 'net',
> 
> But once you add feature changes and cleanups, then 'net' is not
> appropriate.
> 
> Please split this up properly and submit things targetting the
> correct GIT tree.

OK. You are right. Regarding this series I was a little bit imprecise
about the topic. Actually only the first patch is no fix but adds code
simplification. I forget that one in the last pull request. The other
four are all adding features. The whole series sits on top of net-next.

Sorry for the confusion. I hope this series can be applied as is.

Thanks,
Michael

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
