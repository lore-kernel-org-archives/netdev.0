From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qdisc: meta return ENOMEM on alloc failure
Date: Mon, 30 Sep 2013 15:48:22 -0400 (EDT)
Message-ID: <20130930.154822.1621790783772285147.davem@davemloft.net>
References: <20130926174011.22632779@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756215Ab3I3TsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:48:25 -0400
In-Reply-To: <20130926174011.22632779@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 26 Sep 2013 17:40:11 -0700

> Rather than returning earlier value (EINVAL), return ENOMEM if
> kzalloc fails. Found while reviewing to find another EINVAL condition.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
