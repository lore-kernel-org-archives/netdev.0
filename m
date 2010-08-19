From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Thu, 19 Aug 2010 17:48:51 +0200
Message-ID: <201008191748.51819.arnd@arndb.de>
References: <cover.1281956490.git.richard.cochran@omicron.at> <201008191429.50008.arnd@arndb.de> <20100819152301.GB25193@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	Rodolfo Giometti <giometti@linux.it>,
	john stultz <johnstul@us.ibm.com>,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61140 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab0HSPsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 11:48:50 -0400
In-Reply-To: <20100819152301.GB25193@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 August 2010, Ira W. Snyder wrote:
> Perhaps you were thinking of the vhost example (taken from
> drivers/vhost/Kconfig):
> 
> config VHOST_NET
>         tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
>         depends on NET && EVENTFD && (TUN || !TUN) && (MACVTAP || !MACVTAP) && EXPERIMENTAL
> 
> They have a similar construct with both TUN and MACVTAP there. Perhaps
> the parens are a necessary part of the "X || !X" syntax? Just a random
> guess.

Yes, that's the one I was thinking of.

My mistake was that the effect is slightly different here. VHOST and TUN are
both tristate. What we guarantee here is that if TUN is "m", VHOST cannot be "y",
because its dependency cannot be fulfilled for y.

	Arnd
