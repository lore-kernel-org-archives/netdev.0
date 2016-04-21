From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] tcp: Merge timestamp info when coalescing skbs
Date: Thu, 21 Apr 2016 14:41:21 -0400 (EDT)
Message-ID: <20160421.144121.2238207255310352684.davem@davemloft.net>
References: <1461130769-1442865-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
	soheil@google.com, willemb@google.com, ycheng@google.com,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbcDUSlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:41:23 -0400
In-Reply-To: <1461130769-1442865-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 19 Apr 2016 22:39:27 -0700

> This series is separated from the RFC series related to
> tcp_sendmsg(MSG_EOR) and it is targeting for the net branch.
> This patchset is focusing on fixing cases where TCP
> timestamp could be lost after coalescing skbs.
> 
> A BPF prog is used to kprobe to sock_queue_err_skb()
> and print out the value of serr->ee.ee_data.  The BPF
> prog (run-able from bcc) is attached here:
 ...

Series applied, thank you.
