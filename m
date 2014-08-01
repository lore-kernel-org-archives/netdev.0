From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/5] net-timestamp: additional sw tstamps
 and
Date: Thu, 31 Jul 2014 22:35:02 -0700 (PDT)
Message-ID: <20140731.223502.1817836164659773906.davem@davemloft.net>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
	<20140731.134330.1615160836103431950.davem@davemloft.net>
	<CA+FuTSe1T4-CtK88rBrm_yymer5iEPR7f8p-+bYHSW_4zMpAUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaHAFfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:35:05 -0400
In-Reply-To: <CA+FuTSe1T4-CtK88rBrm_yymer5iEPR7f8p-+bYHSW_4zMpAUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 31 Jul 2014 17:36:16 -0400

> An earlier internal version of the patch did not lock the buffers,
> but recorded the seqno in skb_shared_info and referenced that in
> these cases. The obvious drawback is having to store an u32 in
> skb_shinfo. We did just regain 64b with the removal of syststamp,
> though. Would this be a reasonable approach?

At the time we were discussing the removal syststamp, the intention
was to use that space for a new value that can be use to match up
timestamps properly with the packets they are for.

Originally you wanted to use skb->mark for this and then we discussed
all of the drawbacks and shortcoming of that.

What happened to those plans?

Also, there might be 4 bytes available in tcp_skb_cb.
