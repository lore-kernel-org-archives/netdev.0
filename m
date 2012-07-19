From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] TCP Fast Open client
Date: Thu, 19 Jul 2012 10:56:16 -0700 (PDT)
Message-ID: <20120719.105616.2007996793203344140.davem@davemloft.net>
References: <1342716191-19196-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, ncardwell@google.com,
	sivasankar@cs.ucsd.edu, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2GSR4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:56:18 -0400
In-Reply-To: <1342716191-19196-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 19 Jul 2012 09:43:04 -0700

> ChangeLog since v2:
>   - Added seqlock to update Fast Open metrics
>   - Move TCP magic code in inet_wait_for_connect() to inet_stream_connect()
>   - Move up MSG_FASTOPEN macro for better header formatting
> 
> ChangeLog since v1:
>   - Reduce tons of code by storing Fast Open stats in the TCP metrics :)
>   - Clarify the purpose of using an experimental option in patch 1/7

Ok I've applied this series and am doing build testing, if nothing
falls out from that I'll push it out to net-next.

Thanks a lot for doing this work.
