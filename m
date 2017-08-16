From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 2/2] bpf: sock_map fixes for !CONFIG_BPF_SYSCALL
 and !STREAM_PARSER
Date: Thu, 17 Aug 2017 00:11:41 +0200
Message-ID: <5994C31D.7010803@iogearbox.net>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810> <20170816220232.25438.47447.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net,
        eric.dumazet@gmail.com, dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54391 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752352AbdHPWLo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:11:44 -0400
In-Reply-To: <20170816220232.25438.47447.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 12:02 AM, John Fastabend wrote:
> Resolve issues with !CONFIG_BPF_SYSCALL and !STREAM_PARSER
>
> net/core/filter.c: In function ‘do_sk_redirect_map’:
> net/core/filter.c:1881:3: error: implicit declaration of function ‘__sock_map_lookup_elem’ [-Werror=implicit-function-declaration]
>     sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
>     ^
> net/core/filter.c:1881:6: warning: assignment makes pointer from integer without a cast [enabled by default]
>     sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
