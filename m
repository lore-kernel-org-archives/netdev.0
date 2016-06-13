From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] tcp: return sizeof tcp_dctcp_info in dctcp_get_info()
Date: Mon, 13 Jun 2016 17:47:41 +0200
Message-ID: <575ED59D.2000908@iogearbox.net>
References: <1465831235-29876-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Soheil Hassas Yeganeh <soheil@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60458 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424144AbcFMPrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 11:47:45 -0400
In-Reply-To: <1465831235-29876-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2016 05:20 PM, Neal Cardwell wrote:
> Make sure that dctcp_get_info() returns only the size of the
> info->dctcp struct that it zeroes out and fills in. Previously it had
> been returning the size of the enclosing tcp_cc_info union,
> sizeof(*info).  There is no problem yet, but that union that may one
> day be larger than struct tcp_dctcp_info, in which case the
> TCP_CC_INFO code might accidentally copy uninitialized bytes from the
> stack.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
