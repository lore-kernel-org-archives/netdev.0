From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/5] xdp: make generic xdp redirect use tracepoint
 trace_xdp_redirect
Date: Tue, 22 Aug 2017 23:21:39 +0200
Message-ID: <599CA063.8060100@iogearbox.net>
References: <150343479290.31091.8019008896152616977.stgit@firesoul> <150343484470.31091.11187498529801746935.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60177 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752375AbdHVVVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:21:40 -0400
In-Reply-To: <150343484470.31091.11187498529801746935.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2017 10:47 PM, Jesper Dangaard Brouer wrote:
> If the xdp_do_generic_redirect() call fails, it trigger the
> trace_xdp_exception tracepoint.  It seems better to use the same
> tracepoint trace_xdp_redirect, as the native xdp_do_redirect{,_map} does.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Makes sense to make this consistent.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
