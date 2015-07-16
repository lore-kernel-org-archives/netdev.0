From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: don't use F-RTO on non-recurring timeouts
Date: Wed, 15 Jul 2015 17:17:56 -0700 (PDT)
Message-ID: <20150715.171756.691061883175724526.davem@davemloft.net>
References: <1436814620-5889-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbbGPAR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 20:17:57 -0400
In-Reply-To: <1436814620-5889-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 13 Jul 2015 12:10:20 -0700

> Currently F-RTO may repeatedly send new data packets on non-recurring
> timeouts in CA_Loss mode. This is a bug because F-RTO (RFC5682)
> should only be used on either new recovery or recurring timeouts.
> 
> This exacerbates the recovery progress during frequent timeout &
> repair, because we prioritize sending new data packets instead of
> repairing the holes when the bandwidth is already scarce.
> 
> Fix it by correcting the test of a new recovery episode.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thank you.
