From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: kill useless net_*_ingress_queue()
 definitions when NET_CLS_ACT is unset
Date: Wed, 13 May 2015 15:45:05 -0400 (EDT)
Message-ID: <20150513.154505.120630567766890421.davem@davemloft.net>
References: <1431455287-4925-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965254AbbEMTpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:45:07 -0400
In-Reply-To: <1431455287-4925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 12 May 2015 20:28:07 +0200

> This fixes 4577139b2dabf589 ("net: use jump label patching for ingress qdisc in
> __netif_receive_skb_core").
> 
> The only client of this is sch_ingress and it depends on NET_CLS_ACT. So
> there is no way these definition can be of any help.
> 
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks Pablo.
