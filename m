From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [V2 PATCH net-next 2/2] xdp: catch invalid XDP_REDIRECT API usage
Date: Thu, 07 Sep 2017 16:32:44 +0200
Message-ID: <59B1588C.8080908@iogearbox.net>
References: <150478756604.28665.6915020425359475729.stgit@firesoul> <150478759820.28665.14031878598812204399.stgit@firesoul> <59B15403.2090109@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        alexei.starovoitov@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37589 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754005AbdIGOcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:32:47 -0400
In-Reply-To: <59B15403.2090109@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2017 04:13 PM, Daniel Borkmann wrote:
[...]
> +            uint64_t addr = (unsigned long)prog;

And of course: s/uint64_t/u64/. Lack of context switch. ;-)
