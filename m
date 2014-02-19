From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window
 transitions
Date: Wed, 19 Feb 2014 13:17:08 -0500 (EST)
Message-ID: <20140219.131708.562226572566677127.davem@davemloft.net>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbaBSSRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 13:17:10 -0500
In-Reply-To: <1392674268-26005-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 17 Feb 2014 22:57:48 +0100

> Three counters are added:
> - one to track when we went from non-zero to zero window
> - one to track the reverse
> - one counter incremented when we want to announce zero window.
> 
> The latter is added because it can show cases where we want to close the
> window but can't because we would shrink window.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Eric, is this what you had in mind?
> 
>  I re-ran my 'slow-sender-with-reader-that-does-not-drain-socket'
>  scenario and, as expected, only TCPWANTZEROWINDOW increases.

Eric, ping?
