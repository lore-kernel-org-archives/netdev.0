From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] pull request for net-next: batman-adv 2016-07-04
Date: Mon, 04 Jul 2016 23:37:25 -0700 (PDT)
Message-ID: <20160704.233725.776967939409818077.davem@davemloft.net>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: sw@simonwunderlich.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbcGEGh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 02:37:26 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>
Date: Mon,  4 Jul 2016 15:02:48 +0200

> this is our second and final feature pull request for batman-adv in this
> round.
> 
> Please pull or let me know of any problem!

Pulled, thanks.

I have no idea why you guys were using debugfs for anything that
actually matters like configuration. :-/  debugfs should only be
used for "debugging", such that if debugfs were not present the
full functionality of the facility would still be present.
