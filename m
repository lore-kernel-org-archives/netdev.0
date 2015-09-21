From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] geneve: remove use of internal IP header when
 calling IP_ECN_decapsulate
Date: Sun, 20 Sep 2015 22:24:59 -0700 (PDT)
Message-ID: <20150920.222459.2251924175671848436.davem@davemloft.net>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
	<1442522094-876-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182AbbIUFZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:25:00 -0400
In-Reply-To: <1442522094-876-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 17 Sep 2015 16:34:54 -0400

> This seems to have been a "thinko".  IP_ECN_decapsulate needs info
> from both internal and external headers.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> v2 -- ensure the collect_md path still calls IP_ECN_decapsulate

Judging by the discussion on this patch, I expect that this will
be respun to make the TX path match what we'll be doing in the RX
path here.
