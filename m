From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/7] netfilter: nfnetlink_queue: fix incorrect initialization
 of copy range field
Date: Wed, 20 Mar 2013 17:33:01 +0400
Message-ID: <5149BA8D.8030607@cogentembedded.com>
References: <1363776574-4766-1-git-send-email-pablo@netfilter.org> <1363776574-4766-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:44626 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755243Ab3CTNdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 09:33:55 -0400
Received: by mail-la0-f44.google.com with SMTP id eb20so2981306lab.17
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 06:33:50 -0700 (PDT)
In-Reply-To: <1363776574-4766-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-03-2013 14:49, pablo@netfilter.org wrote:

> From: Pablo Neira Ayuso <pablo@netfilter.org>

> 2^16 = 0xffff,

    2^16-1, to be precise.

> not 0xfffff (note the extra 'f'). Not dangerous since you
> adjust it to min_t(data_len, skb->len) just after on.

> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

WBR, Sergei
