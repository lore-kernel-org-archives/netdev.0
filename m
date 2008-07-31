From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 03:49:04 -0700 (PDT)
Message-ID: <20080731.034904.190066778.davem@davemloft.net>
References: <20080731092703.661994657@free-electrons.com>
	<20080731093221.236840420@free-electrons.com>
	<20080731104004.GN10471@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, linux-kernel@vger.kernel.org,
	linux-embedded@vger.kernel.org, michael@free-electrons.com,
	mpm@selenic.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54853
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbYGaKtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:49:04 -0400
In-Reply-To: <20080731104004.GN10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 31 Jul 2008 11:40:05 +0100

> You also need to conditionalise dev_disable_lro().

That can only be done once the CONFIG_ETHTOOL select statement
is added for CONFIG_INET.

Which basically makes this CONFIG_ETHTOOL thing completely pointless.
