From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: Generalize ndo_gso_check to
 ndo_features_check
Date: Fri, 26 Dec 2014 17:21:23 -0500 (EST)
Message-ID: <20141226.172123.100190861218555106.davem@davemloft.net>
References: <1419403046-43165-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	joestringer@nicira.com, edumazet@google.com, hayeswang@realtek.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaLZWV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 17:21:26 -0500
In-Reply-To: <1419403046-43165-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 23 Dec 2014 22:37:26 -0800

> GSO isn't the only offload feature with restrictions that
> potentially can't be expressed with the current features mechanism.
> Checksum is another although it's a general issue that could in
> theory apply to anything. Even if it may be possible to
> implement these restrictions in other ways, it can result in
> duplicate code or inefficient per-packet behavior.
> 
> This generalizes ndo_gso_check so that drivers can remove any
> features that don't make sense for a given packet, similar to
> netif_skb_features(). It also converts existing driver
> restrictions to the new format, completing the work that was
> done to support tunnel protocols since the issues apply to
> checksums as well.
> 
> By actually removing features from the set that are used to do
> offloading, it solves another problem with the existing
> interface. In these cases, GSO would run with the original set
> of features and not do anything because it appears that
> segmentation is not required.
> 
> CC: Tom Herbert <therbert@google.com>
> CC: Joe Stringer <joestringer@nicira.com>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Hayes Wang <hayeswang@realtek.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> Acked-by:  Tom Herbert <therbert@google.com>
> Fixes: 04ffcb255f22 ("net: Add ndo_gso_check")

Applied and queued up for -stable, thanks.
