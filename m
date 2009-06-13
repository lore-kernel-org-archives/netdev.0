From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Fri, 12 Jun 2009 17:01:28 -0700 (PDT)
Message-ID: <20090612.170128.213931980.davem@davemloft.net>
References: <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com>
	<20090611.170948.66762524.davem@davemloft.net>
	<ba4215e10906120519o35358caducfdd253c9f8d8bd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: mfuzzey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45196
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750880AbZFMAB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 20:01:27 -0400
In-Reply-To: <ba4215e10906120519o35358caducfdd253c9f8d8bd2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Fuzzey <mfuzzey@gmail.com>
Date: Fri, 12 Jun 2009 14:19:11 +0200

> The smc9x driver contains this comment :
> /*
>  * The internal workings of the driver.  If you are changing anything
>  * here with the SMC stuff, you should have the datasheet and know
>  * what you are doing.
>  */
> Before writing this patch I had to disregard this to do the hacked version.
> I wasn't touching the driver to improve it or fix it - in which case
> it would be quite reasonable to expect me to have read the datasheet
> but just to turn off a bit of functionality to work around broken
> hardware.

I don't expect anyone to be required to read a data-sheet just to
prevent some link mode settings.

If the driver isn't clean enough to make a change like that easy,
that's a bug.

This is just a scarecrow argument.
