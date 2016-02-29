From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next] net: remove skb_sender_cpu_clear()
Date: Mon, 29 Feb 2016 19:50:15 +0100
Message-ID: <56D492E7.4060900@iogearbox.net>
References: <1456633194-2510-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56617 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbcB2SuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 13:50:19 -0500
In-Reply-To: <1456633194-2510-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2016 05:19 AM, Cong Wang wrote:
> After commit 52bd2d62ce67 ("net: better skb->sender_cpu and skb->napi_id cohabitation")
> skb_sender_cpu_clear() becomes empty and can be removed.
>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Wasn't the intention to keep this helper as a marker when packet
crosses domains from RX to TX, see discussion here:

   https://patchwork.ozlabs.org/patch/527167/

Maybe better to rename it and add a comment into the helper to
make the intention more clear?
