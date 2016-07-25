From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] udp: use sk_filter_trim_cap for udp{,6}_queue_rcv_skb
Date: Mon, 25 Jul 2016 12:48:10 -0400
Message-ID: <CAF=yD-JzDKh_YTA++t0EuRZYiL0Ou_SqOyiTUiqMHovhC85Grg@mail.gmail.com>
References: <0a5ec5a7e99c314f5f5f56f37380b70f8a5bc4ad.1469462373.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:33284 "EHLO
	mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbcGYQsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 12:48:50 -0400
Received: by mail-vk0-f66.google.com with SMTP id s189so14561670vkh.0
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 09:48:50 -0700 (PDT)
In-Reply-To: <0a5ec5a7e99c314f5f5f56f37380b70f8a5bc4ad.1469462373.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2016 at 12:06 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> After a612769774a3 ("udp: prevent bugcheck if filter truncates packet
> too much"), there followed various other fixes for similar cases such
> as f4979fcea7fd ("rose: limit sk_filter trim to payload").
>
> Latter introduced a new helper sk_filter_trim_cap(), where we can pass
> the trim limit directly to the socket filter handling. Make use of it
> here as well with sizeof(struct udphdr) as lower cap limit and drop the
> extra skb->len test in UDP's input path.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Willem de Bruijn <willemb@google.com>
