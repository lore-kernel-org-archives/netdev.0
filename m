From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] ARCNET: features and fixes
Date: Sun, 18 Oct 2015 20:19:42 -0700 (PDT)
Message-ID: <20151018.201942.595687134692884924.davem@davemloft.net>
References: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbbJSDDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 23:03:25 -0400
In-Reply-To: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Fri, 16 Oct 2015 13:00:54 +0200

> This series includes some small fixes. The main changes are the correct
> xceiver handling (enable/disable) of the com20020 cards. The driver now handles
> link status change detection. The EAE PCI-ARCNET cards now make use of the
> rotary encoded subdevice indexing and got support for led triggers on transmit
> and reconnection events.

If you mix features and bug fixes, then it's ambiguous which tree these
changes should go into.

If it's just fixes, then it's clearly 'net',

But once you add feature changes and cleanups, then 'net' is not
appropriate.

Please split this up properly and submit things targetting the
correct GIT tree.

Thanks.
