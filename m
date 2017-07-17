From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] samples/bpf: add option for native and skb mode
 for redirect apps
Date: Mon, 17 Jul 2017 22:43:28 +0200
Message-ID: <596D2170.1010200@iogearbox.net>
References: <1500322459-3743-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38608 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdGQUng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 16:43:36 -0400
In-Reply-To: <1500322459-3743-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2017 10:14 PM, Andy Gospodarek wrote:
> When testing with a driver that has both native and generic redirect support:
>
> $ sudo ./samples/bpf/xdp_redirect -N 5 6
> input: 5 output: 6
> ifindex 6:    4961879 pkt/s
> ifindex 6:    6391319 pkt/s
> ifindex 6:    6419468 pkt/s
>
> $ sudo ./samples/bpf/xdp_redirect -S 5 6
> input: 5 output: 6
> ifindex 6:    1845435 pkt/s
> ifindex 6:    3882850 pkt/s
> ifindex 6:    3893974 pkt/s
>
> $ sudo ./samples/bpf/xdp_redirect_map -N 5 6
> input: 5 output: 6
> map[0] (vports) = 4, map[1] (map) = 5, map[2] (count) = 0
> ifindex 6:    2207374 pkt/s
> ifindex 6:    6212869 pkt/s
> ifindex 6:    6286515 pkt/s
>
> $ sudo ./samples/bpf/xdp_redirect_map -S 5 6
> input: 5 output: 6
> map[0] (vports) = 4, map[1] (map) = 5, map[2] (count) = 0
> ifindex 6:    5052528 pkt/s
> ifindex 6:    5736631 pkt/s
> ifindex 6:    5739962 pkt/s
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
