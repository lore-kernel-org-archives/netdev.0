From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: prepare CC get_info() access from getsockopt()
Date: Tue, 28 Apr 2015 20:58:09 -0400
Message-ID: <CADVnQy=sbhVk2fenrXd3QiVHx7n1pLZWyHDQcZuhRE6pKCWovQ@mail.gmail.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	<1430263429-4069-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34581 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031191AbbD2A6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 20:58:10 -0400
Received: by oiko83 with SMTP id o83so10331373oik.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 17:58:10 -0700 (PDT)
In-Reply-To: <1430263429-4069-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 7:23 PM, Eric Dumazet <edumazet@google.com> wrote:
> We would like that optional info provided by Congestion Control
> modules using netlink can also be read using getsockopt()
>
> This patch changes get_info() to put this information in a buffer,
> instead of skb, like tcp_get_info(), so that following patch
> can reuse this common infrastructure.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
