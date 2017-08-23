From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/5] bpf/verifier: when pruning a branch,
 ignore its write marks
Date: Wed, 23 Aug 2017 16:56:59 +0200
Message-ID: <599D97BB.7070604@iogearbox.net>
References: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com> <ec2ee579-8391-c023-348a-770faa6bc5c7@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47345 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754113AbdHWO5M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:57:12 -0400
In-Reply-To: <ec2ee579-8391-c023-348a-770faa6bc5c7@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 04:10 PM, Edward Cree wrote:
> The fact that writes occurred in reaching the continuation state does
>   not screen off its reads from us, because we're not really its parent.
> So detect 'not really the parent' in do_propagate_liveness, and ignore
>   write marks in that case.
>
> Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
