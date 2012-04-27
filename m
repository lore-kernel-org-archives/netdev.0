From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: clean up use of jiffies in tcp_rcv_rtt_measure()
Date: Fri, 27 Apr 2012 17:56:26 +0200
Message-ID: <1335542186.2775.247.camel@edumazet-glaptop>
References: <1335540577-32554-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>, ilpo.jarvinen@helsinki.fi,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61360 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760569Ab2D0P4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 11:56:33 -0400
Received: by bkuw12 with SMTP id w12so629625bku.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 08:56:31 -0700 (PDT)
In-Reply-To: <1335540577-32554-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 11:29 -0400, Neal Cardwell wrote:
> Clean up a reference to jiffies in tcp_rcv_rtt_measure() that should
> instead reference tcp_time_stamp. Since the result of the subtraction
> is passed into a function taking u32, this should not change any
> behavior (and indeed the generated assembly does not change on
> x86_64). However, it seems worth cleaning this up for consistency and
> clarity (and perhaps to avoid bugs if this is copied and pasted
> somewhere else).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
