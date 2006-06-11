From: Ulrich Kunitz <kune@deine-taler.de>
Subject: IEEE80211 Regulatory/Geographical Support for WLAN driver
Date: Sun, 11 Jun 2006 22:21:14 +0200
Message-ID: <20060611202114.GA26884@p15091797.pureserver.info>
References: <448210EF.10103@lwfinger.net> <20060611100750.GF24167@p15091797.pureserver.info> <448C48CF.50205@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:24787 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750946AbWFKUVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 16:21:15 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <448C48CF.50205@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-06-11 11:46 Larry Finger wrote:

> I don't see any means for the daemon to know its country other than the 
> driver or the user telling it. If such a means exists, I would like to 
> learn of it. My current working model is to supply the country code from a 
> module option when the driver is loaded.

I thought about a config option. However thinking about they whole
thing more, I believe the functionality of your daemon should be
included into WPA supplicant and should use it's user space
communication mechanisms. It will become the universal WLAN user
space daemon anyhow. The second best option would be to extend
udev and reuse the firmware loading code.

BTW creating a file with 0666 is almost always a bad idea, even if
it exists only a "short" time. 

Kind regards,

Uli

-- 
Uli Kunitz
