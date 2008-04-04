From: David Miller <davem@davemloft.net>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
 driver
Date: Fri, 04 Apr 2008 15:05:30 -0700 (PDT)
Message-ID: <20080404.150530.225808747.davem@davemloft.net>
References: <Pine.SOC.4.64.0804041154150.11646@math.ut.ee>
	<47F6A4DC.3070504@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, netdev@vger.kernel.org, grundler@parisc-linux.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751653AbYDDWF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 18:05:29 -0400
In-Reply-To: <47F6A4DC.3070504@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 04 Apr 2008 17:59:56 -0400

> A zeroed MAC address leads me to believe that dmfe's SROM parsing isn't 
> quite as capable as tulip's, though that's just a guess.
> 
> Just checked dmfe with sparse and it reports clean, though looking at 
> the code it could use some cleanups.

The sparc64 onboard davicoms don't indicate anything in the
SROM area.

Properties such as MAC addresses need to be obtained via
openfirmware probing methods.
