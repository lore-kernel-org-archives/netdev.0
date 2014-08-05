From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reduce spurious retransmits due to
 transient SACK reneging
Date: Tue, 05 Aug 2014 16:29:52 -0700 (PDT)
Message-ID: <20140805.162952.959546833947302604.davem@davemloft.net>
References: <1407193949-14921-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbaHEX3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:29:53 -0400
In-Reply-To: <1407193949-14921-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon,  4 Aug 2014 19:12:29 -0400

> This commit reduces spurious retransmits due to apparent SACK reneging
> by only reacting to SACK reneging that persists for a short delay.
 ...
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Looks great, applied, thanks!
