From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 12/12] netxen: update version to 4.0.41
Date: Mon, 27 Jul 2009 12:38:07 -0700 (PDT)
Message-ID: <20090727.123807.268367807.davem@davemloft.net>
References: <20090727.103842.52201957.davem@davemloft.net>
	<20090727.105403.202219074.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D56581877E22A4@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753192AbZG0TiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 15:38:01 -0400
In-Reply-To: <7608421F3572AB4292BB2532AE89D56581877E22A4@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Mon, 27 Jul 2009 12:26:58 -0700

> Ok, the idea for module params was to set global defaults
> (configured in modprobe.conf) vs. per interface ethtool calls.
> The ethtool support is anyway added by # 12 patch.
> 
> Is it not good to have both options available? 

No, it is not good.

With module parameters we:

1) duplicate functionality

2) every device driver will name the module parms differently,
   therefore the interface for the user is different for every device
   type

We discuss this all the time, and this is a pretty deep rooted
belief and requirement for all network drivers.
