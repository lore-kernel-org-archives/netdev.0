From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] tcp: prepare CC get_info() access from getsockopt()
Date: Wed, 29 Apr 2015 09:55:16 +0200
Message-ID: <55408E64.1050306@iogearbox.net>
References: <1430263429-4069-1-git-send-email-edumazet@google.com> <1430263429-4069-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44179 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031285AbbD2HzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 03:55:21 -0400
In-Reply-To: <1430263429-4069-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2015 01:23 AM, Eric Dumazet wrote:
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

Looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
