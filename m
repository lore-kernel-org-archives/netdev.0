From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] sky2: receive checksum refactoring
Date: Wed, 10 Feb 2010 17:57:55 -0800 (PST)
Message-ID: <20100210.175755.120225353.davem@davemloft.net>
References: <20100207082353.2d0c6a93@nehalam>
	<20100207082836.22a7b296@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755547Ab0BKB5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 20:57:41 -0500
In-Reply-To: <20100207082836.22a7b296@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 7 Feb 2010 08:28:36 -0800

> Break the largish case for handling receive checksum into a separate
> function, and if there is a problem use dev_XXX routines to
> show which hardware is the problem.
> 
> Turn one corner case into a BUG().  This only happens if the driver
> is expecting one behavior but the chip does the old behavior;
> only ever saw this when bringing up a new chip type and driver
> was buggy.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
