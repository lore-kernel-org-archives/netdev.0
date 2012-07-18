From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 7/7] net-tcp: Fast Open client - cookie-less mode
Date: Wed, 18 Jul 2012 23:36:42 +0200
Message-ID: <1342647402.2626.3723.camel@edumazet-glaptop>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	 <1342645307-17772-8-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:41084 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab2GRVgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:36:47 -0400
Received: by ghrr11 with SMTP id r11so2119071ghr.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:36:47 -0700 (PDT)
In-Reply-To: <1342645307-17772-8-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0700, Yuchung Cheng wrote:
> In trusted networks, e.g., intranet, data-center, the client does not
> need to use Fast Open cookie to mitigate DoS attacks. In cookie-less
> mode, sendmsg() with MSG_FASTOPEN flag will send SYN-data regardless
> of cookie availability.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  Documentation/networking/ip-sysctl.txt |    2 ++
>  include/linux/tcp.h                    |    1 +
>  include/net/tcp.h                      |    1 +
>  net/ipv4/tcp_input.c                   |    8 ++++++--
>  net/ipv4/tcp_output.c                  |    6 +++++-
>  5 files changed, 15 insertions(+), 3 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
