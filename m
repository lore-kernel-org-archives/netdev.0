From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: kill useless net_*_ingress_queue() definitions
 when NET_CLS_ACT is unset
Date: Tue, 12 May 2015 20:26:17 +0200
Message-ID: <555245C9.4040403@iogearbox.net>
References: <1431455287-4925-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38583 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932996AbbELS0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 14:26:19 -0400
In-Reply-To: <1431455287-4925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2015 08:28 PM, Pablo Neira Ayuso wrote:
> This fixes 4577139b2dabf589 ("net: use jump label patching for ingress qdisc in
> __netif_receive_skb_core").
>
> The only client of this is sch_ingress and it depends on NET_CLS_ACT. So
> there is no way these definition can be of any help.
>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
