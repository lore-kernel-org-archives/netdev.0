From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] soreuseport: pass skb to secondary UDP socket
 lookup
Date: Wed, 06 Jan 2016 01:28:42 -0500 (EST)
Message-ID: <20160106.012842.45222212579285054.davem@davemloft.net>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcAFG2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 01:28:44 -0500
In-Reply-To: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue,  5 Jan 2016 15:08:07 -0500

> From: Craig Gallek <kraig@google.com>
> 
> This socket-lookup path did not pass along the skb in question
> in my original BPF-based socket selection patch.  The skb in the
> udpN_lib_lookup2 path can be used for BPF-based socket selection just
> like it is in the 'traditional' udpN_lib_lookup path.
> 
> udpN_lib_lookup2 kicks in when there are greater than 10 sockets in
> the same hlist slot.  Coincidentally, I chose 10 sockets per
> reuseport group in my functional test, so the lookup2 path was not
> excersised. This adds an additional set of tests with 20 sockets.
> 
> Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
> Fixes: 3ca8e4029969 ("soreuseport: BPF selection functional test")
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied, thanks Craig.
