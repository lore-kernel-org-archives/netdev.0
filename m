From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc75xx: don't call usbnet_resume if usbnet_suspend
 fails
Date: Wed, 28 Nov 2012 21:03:52 -0500 (EST)
Message-ID: <20121128.210352.2215853651070474894.davem@davemloft.net>
References: <1354125469-29671-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab2K2CDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 21:03:53 -0500
In-Reply-To: <1354125469-29671-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Wed, 28 Nov 2012 17:57:49 +0000

> If usbnet_suspend returns an error we don't want to call
> usbnet_resume to clean up, but instead just return the error.
> 
> If usbnet_suspend *does* succeed, and we have a problem further
> on, the desired behaviour is still to call usbnet_resume
> to clean up before returning.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Steve, can you do me a huge favor?

Get rid of these silly macros from this driver.

Any CPP macro that alters control flow is too evil to live.  And we've
worked tirelessly to remove every instance of such a macro from the
core networking interfaces, because they always lead to hard to
diagnose bugs.

THanks.
