From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ieee802154: reassembly: fix possible buffer
 overflow
Date: Wed, 02 Jul 2014 18:35:07 -0700 (PDT)
Message-ID: <20140702.183507.834058752545345423.davem@davemloft.net>
References: <1404040218-31122-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaGCBfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:35:09 -0400
In-Reply-To: <1404040218-31122-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Sun, 29 Jun 2014 13:10:18 +0200

> The max_dsize attribute in ctl_table for lowpan_frags_ns_ctl_table is
> configured with integer accessing methods. This patch change the
> max_dsize attribute to int to avoid a possible buffer overflow.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

Applied, thanks.
