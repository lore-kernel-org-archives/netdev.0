From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/3] samples/bpf: add static to function with
 no prototype
Date: Mon, 24 Apr 2017 16:40:21 +0200
Message-ID: <58FE0E55.2000303@iogearbox.net>
References: <20170424133108.31595-1-alexander@alemayhu.com> <20170424133108.31595-3-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: ast@fb.com
To: Alexander Alemayhu <alexander@alemayhu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58028 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172591AbdDXOkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:40:22 -0400
In-Reply-To: <20170424133108.31595-3-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2017 03:31 PM, Alexander Alemayhu wrote:
> Fixes the following warning
>
> samples/bpf/cookie_uid_helper_example.c: At top level:
> samples/bpf/cookie_uid_helper_example.c:276:6: warning: no previous prototype for ‘finish’ [-Wmissing-prototypes]
>   void finish(int ret)
>        ^~~~~~
>    HOSTLD  samples/bpf/per_socket_stats_example
>
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
