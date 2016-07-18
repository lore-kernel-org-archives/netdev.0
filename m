From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] sctp: load transport header after sk_filter
Date: Mon, 18 Jul 2016 10:20:02 +0200
Message-ID: <578C9132.2060106@iogearbox.net>
References: <1468704795-134034-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>,
	marcelo.leitner@gmail.com
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38507 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbcGRIUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 04:20:06 -0400
In-Reply-To: <1468704795-134034-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2016 11:33 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Do not cache pointers into the skb linear segment across sk_filter.
> The function call can trigger pskb_expand_head.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Fix looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
