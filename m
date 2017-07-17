From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] samples/bpf: add option for native and skb mode
 for redirect apps
Date: Mon, 17 Jul 2017 13:19:40 -0700
Message-ID: <596D1BDC.3020004@gmail.com>
References: <1500322459-3743-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35866 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdGQUTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 16:19:53 -0400
Received: by mail-pg0-f53.google.com with SMTP id u5so134655pgq.3
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 13:19:53 -0700 (PDT)
In-Reply-To: <1500322459-3743-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2017 01:14 PM, Andy Gospodarek wrote:
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
> ---


Looks good, thanks.

Acked-by: John Fastabend <john.fastabend@gmail.com>
