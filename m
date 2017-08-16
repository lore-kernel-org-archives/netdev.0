From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 1/2] bpf: sockmap state change warning fix
Date: Thu, 17 Aug 2017 00:10:46 +0200
Message-ID: <5994C2E6.2010304@iogearbox.net>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810> <20170816220211.25438.24547.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net,
        eric.dumazet@gmail.com, dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54279 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdHPWKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:10:50 -0400
In-Reply-To: <20170816220211.25438.24547.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 12:02 AM, John Fastabend wrote:
> psock will uninitialized in default case we need to do the same psock lookup
> and check as in other branch. Fixes compile warning below.
>
> kernel/bpf/sockmap.c: In function ‘smap_state_change’:
> kernel/bpf/sockmap.c:156:21: warning: ‘psock’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>    struct smap_psock *psock;
>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Reported-by: David Miller <davem@davemloft.net>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Thanks for fixing up quickly!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
