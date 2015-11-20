From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] tcp: disable Fast Open on timeouts after
 handshake
Date: Fri, 20 Nov 2015 10:52:29 -0500 (EST)
Message-ID: <20151120.105229.472836583674901954.davem@davemloft.net>
References: <1447899451-24584-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbbKTPwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 10:52:31 -0500
In-Reply-To: <1447899451-24584-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 18 Nov 2015 18:17:30 -0800

> Some middle-boxes black-hole the data after the Fast Open handshake
> (https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf).
> The exact reason is unknown. The work-around is to disable Fast Open
> temporarily after multiple recurring timeouts with few or no data
> delivered in the established state.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Christoph Paasch <cpaasch@apple.com>

Applied and queued up for -stable.

Just out of curiosity, why isn't a test for zero data sufficient?

Do these middle-boxes sometimes not black-hole all of the data?
