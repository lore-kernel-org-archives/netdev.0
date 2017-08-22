From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/5] ixgbe: use return codes from ndo_xdp_xmit
 that are distinguishable
Date: Tue, 22 Aug 2017 23:21:59 +0200
Message-ID: <599CA077.1010008@iogearbox.net>
References: <150343479290.31091.8019008896152616977.stgit@firesoul> <150343484979.31091.3667334412617955097.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60224 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751815AbdHVVWA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:22:00 -0400
In-Reply-To: <150343484979.31091.3667334412617955097.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2017 10:47 PM, Jesper Dangaard Brouer wrote:
> For XDP_REDIRECT the use of return code -EINVAL is confusing, as it is
> used in three different cases.  (1) When the index or ifindex lookup
> fails, and in the ixgbe driver (2) when link is down and (3) when XDP
> have not been enabled.
>
> The return code can be picked up by the tracepoint xdp:xdp_redirect
> for diagnosing why XDP_REDIRECT isn't working.  Thus, there is a need
> different return codes to tell the issues apart.
>
> I'm considering using a specific err-code scheme for XDP_REDIRECT
> instead of using these errno codes.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
