From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net v2] be2net: Warn users of possible broken
 functionality on BE2 cards with very old FW versions with latest driver
Date: Mon, 07 Oct 2013 09:44:29 -0700
Message-ID: <1381164269.2081.185.camel@joe-AO722>
References: <cca19523-3f51-4f87-b0e1-2ecec6ba37d4@CMEXHTCAS1.ad.emulex.com>
	 <20131007.123116.1462434377931881914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: somnath.kotur@emulex.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0233.hostedemail.com ([216.40.44.233]:40563 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751634Ab3JGQoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 12:44:32 -0400
In-Reply-To: <20131007.123116.1462434377931881914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-07 at 12:31 -0400, David Miller wrote:
> From: Somnath Kotur <somnath.kotur@emulex.com>
> Date: Thu, 3 Oct 2013 15:34:29 +0530
> > +     if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {
> > +             dev_err(dev, "Firmware version is too old.IRQs may not work\n");
> 
> So many grammatical mistakes in one line.
> 
> First sentence got a period, second one did not.
> 
> Missing space between period and second sentence.

Periods are unnecessary here.
Just use a comma or a dash.

Also, it might be nicer to show the current firmware version too.

Maybe:

		dev_err(dev, "Firmware version is '%s' - Version 5 or higher is required for properly functional IRQs\n",
			adapter->fw_ver);
