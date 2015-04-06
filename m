From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage socket
Date: Mon, 6 Apr 2015 06:59:21 -0700
Message-ID: <CALx6S348YyYxrT+3fcXEFz=w6BYFGZwcQ6iD1PjzVePotioJKw@mail.gmail.com>
References: <20150405.221847.2119086885797169021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, hannes@stressinduktion.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33117 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbbDFN7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 09:59:21 -0400
Received: by iebmp1 with SMTP id mp1so21418392ieb.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 06:59:21 -0700 (PDT)
In-Reply-To: <20150405.221847.2119086885797169021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 5, 2015 at 7:18 PM, David Miller <davem@davemloft.net> wrote:
>
> So this should do the rest of the work such that when we encapsulate
> into a UDP tunnel, the output path works on the UDP tunnel's socket
> rather than skb->sk.
>
Doesn't this contradict "udp: Do not require sock in
udp_tunnel_xmit_skb" patch?  How is the skbuf getting set with a
garbage socket?

Thanks,
Tom

login
register
mail settings
> Part of this work is based upon changes done by Jiri Pirko some time
> ago.
>
> Basically the first step is to pass the socket through the nf_hook
> okfn(), and then next we do the same for the UDP tunnel xmit routines.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
