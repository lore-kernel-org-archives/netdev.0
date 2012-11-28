From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: irttp: fix memory leak in irttp_open_tsap()
 error path
Date: Wed, 28 Nov 2012 11:25:55 -0500 (EST)
Message-ID: <20121128.112555.613351569257823002.davem@davemloft.net>
References: <1353939404-19264-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org, davej@redhat.com
To: tt.rantala@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab2K1QZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:25:58 -0500
In-Reply-To: <1353939404-19264-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommi Rantala <tt.rantala@gmail.com>
Date: Mon, 26 Nov 2012 16:16:44 +0200

> Cleanup the memory we allocated earlier in irttp_open_tsap() when we hit
> this error path. The leak goes back to at least 1da177e4
> ("Linux-2.6.12-rc2").
> 
> Discovered with Trinity (the syscall fuzzer).
> 
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>

Applied, thanks.
