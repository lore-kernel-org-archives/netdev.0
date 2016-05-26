From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/8] qed*: Bug fixes
Date: Thu, 26 May 2016 12:30:56 -0700 (PDT)
Message-ID: <20160526.123056.1476006204775720640.davem@davemloft.net>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbcEZTbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 15:31:00 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 26 May 2016 11:01:16 +0300

> This series contain several small fixes, most of which deal with
> either 100g support, sriov or bandwidth configurations.

Series applied, but in future the GFP_KERNEL fix should be done
differently.

Instead of passing a boolean sleepable state around, pass a "gfp_t"
which makes it clear at the call sites what that argument is
controlling.

That way you wouldn't have that mess of "sleepable ? GFP_X : GFP_Y"
constructs all over the place.
