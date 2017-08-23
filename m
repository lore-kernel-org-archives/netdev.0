From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [V2 PATCH net-next 4/5] xdp: remove net_device names from xdp_redirect
 tracepoint
Date: Wed, 23 Aug 2017 12:58:59 +0200
Message-ID: <599D5FF3.7040604@iogearbox.net>
References: <150348327373.23476.14851572406177222309.stgit@firesoul> <150348333529.23476.10681237706586293307.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40267 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753834AbdHWK7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 06:59:31 -0400
In-Reply-To: <150348333529.23476.10681237706586293307.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 12:15 PM, Jesper Dangaard Brouer wrote:
> There is too much overhead in the current trace_xdp_redirect
> tracepoint as it does strcpy and strlen on the net_device names.
>
> Besides, exposing the ifindex/index is actually the information that
> is needed in the tracepoint to diagnose issues.  When a lookup fails
> (either ifindex or devmap index) then there is a need for saying which
> to_index that have issues.
>
> V2: Adjust args to be aligned with trace_xdp_exception.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
