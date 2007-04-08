From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [XFRM]: esp: fix skb_tail_pointer conversion bug
Date: Sun, 8 Apr 2007 10:07:29 -0300
Message-ID: <39e6f6c70704080607u729e72bbq4ac5fddfe144ef18@mail.gmail.com>
References: <461886F6.1010308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Kernel Netdev Mailing List" <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:31108 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbXDHNHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 09:07:31 -0400
Received: by ik-out-1112.google.com with SMTP id c21so927150ika
        for <netdev@vger.kernel.org>; Sun, 08 Apr 2007 06:07:29 -0700 (PDT)
In-Reply-To: <461886F6.1010308@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/8/07, Patrick McHardy <kaber@trash.net> wrote:
>
> [XFRM]: esp: fix skb_tail_pointer conversion bug
>
> Fix incorrect switch of "trailer" skb by "skb" during skb_tail_pointer
> conversion:
>
> -       *(u8*)(trailer->tail - 1) = top_iph->protocol;
> +       *(skb_tail_pointer(skb) - 1) = top_iph->protocol;
>
> -       *(u8 *)(trailer->tail - 1) = *skb_network_header(skb);
> +       *(skb_tail_pointer(skb) - 1) = *skb_network_header(skb);
>
>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Thanks Patrick, for this one and the other fixes for the offset conversion.

- Arnaldo
