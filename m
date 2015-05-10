From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2 net-next] net: kill useless net_*_ingress_queue()
 definitions when NET_CLS_ACT is unset
Date: Sun, 10 May 2015 19:58:30 +0300
Message-ID: <554F8E36.1040401@cogentembedded.com>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org> <1431277170-4618-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:34602 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbbEJQ6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:58:35 -0400
Received: by laat2 with SMTP id t2so79660504laa.1
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:58:34 -0700 (PDT)
In-Reply-To: <1431277170-4618-2-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/10/2015 7:59 PM, Pablo Neira Ayuso wrote:

> This fixes 4577139 ("net: use jump label patching for ingress qdisc in
> __netif_receive_skb_core").

> The only client of this is sch_ingress and it depends on NET_CLS_ACT. So
> there is no way these definition can be of any use at all.

> Fixes: 4577139 ("net: use jump label patching for ingress qdisc in __netif_receive_skb_core")

    The commit ID is supposed to have 12 digits for this tag.

> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

WBR, Sergei
