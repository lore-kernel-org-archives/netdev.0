From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] soreuseport: fix use of uid in tb->fastuid
Date: Sun, 27 Jan 2013 01:02:05 -0500 (EST)
Message-ID: <20130127.010205.590253560817104896.davem@davemloft.net>
References: <alpine.DEB.2.00.1301260944370.27231@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727Ab3A0GCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 01:02:07 -0500
In-Reply-To: <alpine.DEB.2.00.1301260944370.27231@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sat, 26 Jan 2013 09:50:54 -0800 (PST)

> Fix a reported compilation error where ia variable of type kuid_t
> was being set to zero.
> 
> Eliminate two instances of setting tb->fastuid to zero.  tb->fastuid is 
> only used if tb->fastreuseport is set, so there should be no problem if 
> tb->fastuid is not initialized (when tb->fastreuesport is zero).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
