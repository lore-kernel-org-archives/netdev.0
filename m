From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/5] xdp: remove net_device names from xdp_redirect
 tracepoint
Date: Tue, 22 Aug 2017 23:23:06 +0200
Message-ID: <599CA0BA.2020103@iogearbox.net>
References: <150343479290.31091.8019008896152616977.stgit@firesoul> <150343485489.31091.9423090032200726744.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60336 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751292AbdHVVXI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:23:08 -0400
In-Reply-To: <150343485489.31091.9423090032200726744.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2017 10:47 PM, Jesper Dangaard Brouer wrote:
> There is too much overhead in the current trace_xdp_redirect
> tracepoint as it does strcpy and strlen on the net_device names.
>
> Besides, exposing the ifindex/index is actually the information that
> is needed in the tracepoint to diagnose issues.  When a lookup fails
> (either ifindex or devmap index) then there is a need for saying which
> to_index that have issues.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
