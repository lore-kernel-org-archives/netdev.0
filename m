From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock_diag: don't broadcast kernel sockets
Date: Tue, 30 Jun 2015 10:00:51 -0700 (PDT)
Message-ID: <20150630.100051.61087407377848348.davem@davemloft.net>
References: <1435682972-2703-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@codemonkey.org.uk,
	edumazet@google.com, ebiederm@xmission.com
To: kraig@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbbF3RA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 13:00:56 -0400
In-Reply-To: <1435682972-2703-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>
Date: Tue, 30 Jun 2015 12:49:32 -0400

> Kernel sockets do not hold a reference for the network namespace to
> which they point.  Socket destruction broadcasting relies on the
> network namespace and will cause the splat below when a kernel socket
> is destroyed.
> 
> This fix simply ignores kernel sockets when they are destroyed.
 ...
> Tested:
>   Using a debug kernel while 'ss -E' is running:
>   ip netns add test-ns
>   ip netns delete test-ns
> 
> Fixes: eb4cb008529c sock_diag: define destruction multicast groups
> Fixes: 26abe14379f8 net: Modify sk_alloc to not reference count the
>   netns of kernel sockets.
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

APplied, thanks.
