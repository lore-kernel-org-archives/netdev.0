From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
 driver v2
Date: Thu, 04 Dec 2008 14:37:15 +0100
Message-ID: <1228397835.28839.23.camel@violet.holtmann.net>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <200812021810.59279.inaky@linux.intel.com>
	 <1228381309.3197.17.camel@Friederike-PC.hoffi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	netdev@vger.kernel.org, wimax@linuxwimax.org,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39220 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbYLDNhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 08:37:19 -0500
In-Reply-To: <1228381309.3197.17.camel@Friederike-PC.hoffi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

> > First two ones I plan to tackle ASAP. The dynamic_printk() stuff might take
> > longer and I was wondering if you would be ok with changing that post-29 in
> > case I were about to miss the merge window (got a few very busy weeks
> > ahead of me).
> 
> Fine with me, I guess, I don't even know if the dynprintk is applicable
> (though I'd rather see you make it work if it isn't than add yet another
> huge debug macro file :) )

I switched over the Bluetooth stack to use dynamic_printk(). It is as
easy as just using pr_debug() or dev_dbg(). The rest already works
perfectly fine.

However it is either full debug or nothing. Not a fine grained stuff we
have in the iwlwifi drivers. However not sure if that is actually
needed. It confuses me more and having to unload the driver and reload
it makes me not using it a lot. The dynamic_printk() is really nice
since you can turn it on and off. And since it is on a per module basis
it was enough for Bluetooth. Not sure if that is applicable to
everything, but then it could be extended with debug levels, I guess.

Regards

Marcel


