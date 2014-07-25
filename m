From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] skbedit: allow the user to specify bitmask for mark
Date: Thu, 24 Jul 2014 18:03:23 -0700 (PDT)
Message-ID: <20140724.180323.1810427904757659836.davem@davemloft.net>
References: <1406142815-25537-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	eric.dumazet@gmail.com, cwang@twopensource.com,
	antonio@open-mesh.com, jhs@mojatatu.com
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbaGYBDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 21:03:24 -0400
In-Reply-To: <1406142815-25537-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed, 23 Jul 2014 21:13:35 +0200

> From: Antonio Quartulli <antonio@open-mesh.com>
> 
> The user may want to use only some bits of the skb mark in
> his skbedit rules because the remaining part might be used by
> something else.
> 
> Introduce the "mask" parameter to the skbedit actor in order
> to implement such functionality.
> 
> When the mask is specified, only those bits selected by the
> latter are altered really changed by the actor, while the
> rest is left untouched.
> 
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thank you.
