From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 14:57:27 -0700 (PDT)
Message-ID: <20080730.145727.07367670.davem@davemloft.net>
References: <20080730140136.42223e3c@extreme>
	<20080730233551.76fd38a8@surf>
	<20080730144812.a71156f7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753506AbYG3V51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:57:27 -0400
In-Reply-To: <20080730144812.a71156f7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 30 Jul 2008 14:48:12 -0700

> But I do think we should see some evidence that people are actually
> using CONFIG_ETHTOOL=n in real setups.

Heaven help them if they want to debug any real problems that
might involve checksumming, TSO, and other offload features.
Heaven help them if they want to probe the driver or firmware
version of the card they are using.

I'm sure you can find someone who runs with CONFIG_STAND_ON_MY_HEAD=y
but that doesn't mean that supporting such an option upstream makes
any sense.

We spent years getting rid of the per-driver module parameters to
configure these things.  And now folks want to remove the common
infrastructure we created to do it.

6K is peanuts compared to the per-driver code that implements these
facilities.
