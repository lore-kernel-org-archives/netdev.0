From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: defer sacked assignment
Date: Wed, 17 Aug 2016 10:53:21 -0400
Message-ID: <CADVnQyntPQUJTS6FzTDRVZML8TDJT5Qv=VU4XGtwZOWT81CU_w@mail.gmail.com>
References: <1471445316.4943.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33510 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbcHQOxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:53:52 -0400
Received: by mail-oi0-f48.google.com with SMTP id c15so140955327oig.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:53:52 -0700 (PDT)
In-Reply-To: <1471445316.4943.40.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 10:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> While chasing tcp_xmit_retransmit_queue() kasan issue, I found
> that we could avoid reading sacked field of skb that we wont send,
> possibly removing one cache line miss.
>
> Very minor change in slow path, but why not ? ;)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
