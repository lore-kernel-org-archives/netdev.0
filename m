From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] fix ia64 build failure when CONFIG_SFC=m
Date: Wed, 30 Jul 2008 15:18:26 -0700 (PDT)
Message-ID: <20080730.151826.58205352.davem@davemloft.net>
References: <20080729174839.GG10471@solarflare.com>
	<20080729.140040.72089155.davem@davemloft.net>
	<20080730133527.GI10471@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony.luck@intel.com, jgarzik@redhat.com,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	netdev@vger.kernel.org, matthew@wil.cx, holt@sgi.com,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60760
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752436AbYG3WS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 18:18:27 -0400
In-Reply-To: <20080730133527.GI10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jul 2008 14:35:29 +0100

> So far as I can see, hardly anyone is doing routing at 10G speeds on Linux.
> If they were, the horrible interaction with LRO would presumably have been
> found and fixed earlier.

This assumes a precise intersection between those doing 10G routing
and their using chips with LRO capable drivers.

All of the 10G equipment I have here and do testing on use drivers
that lack LRO support.
