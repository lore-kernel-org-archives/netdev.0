From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 2/7] net-tcp: Fast Open client - cookie cache
Date: Thu, 19 Jul 2012 19:41:13 +0200
Message-ID: <1342719673.2626.4595.camel@edumazet-glaptop>
References: <1342716191-19196-1-git-send-email-ycheng@google.com>
	 <1342716191-19196-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:45464 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab2GSRlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:41:20 -0400
Received: by vcbfk26 with SMTP id fk26so2210751vcb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:41:19 -0700 (PDT)
In-Reply-To: <1342716191-19196-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 09:43 -0700, Yuchung Cheng wrote:
> With help from Eric Dumazet, add Fast Open metrics in tcp metrics cache.
> The basic ones are MSS and the cookies. Later patch will cache more to
> handle unfriendly middleboxes.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/net/tcp.h      |    4 +++
>  net/ipv4/tcp_metrics.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 55 insertions(+), 0 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
