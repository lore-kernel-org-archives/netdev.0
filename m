From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: kill useless net_*_ingress_queue()
 definitions when NET_CLS_ACT is unset
Date: Tue, 12 May 2015 11:32:22 -0700
Message-ID: <20150512183218.GA3620@Alexeis-MBP.westell.com>
References: <1431455287-4925-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, daniel@iogearbox.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35019 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932924AbbELSc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 14:32:26 -0400
Received: by iebpz10 with SMTP id pz10so9825878ieb.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 11:32:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431455287-4925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 08:28:07PM +0200, Pablo Neira Ayuso wrote:
> This fixes 4577139b2dabf589 ("net: use jump label patching for ingress qdisc in
> __netif_receive_skb_core").
> 
> The only client of this is sch_ingress and it depends on NET_CLS_ACT. So
> there is no way these definition can be of any help.
> 
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---

thank you for following up on this one.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
