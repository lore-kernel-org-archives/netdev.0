From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/5] xdp: remove bpf_warn_invalid_xdp_redirect
Date: Tue, 22 Aug 2017 23:19:40 +0200
Message-ID: <599C9FEC.6060501@iogearbox.net>
References: <150343479290.31091.8019008896152616977.stgit@firesoul> <150343483960.31091.3438305938845615426.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59889 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752172AbdHVVTm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:19:42 -0400
In-Reply-To: <150343483960.31091.3438305938845615426.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2017 10:47 PM, Jesper Dangaard Brouer wrote:
> Given there is a tracepoint that can track the error code
> of xdp_do_redirect calls, the WARN_ONCE in bpf_warn_invalid_xdp_redirect
> doesn't seem relevant any longer.  Simply remove the function.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
