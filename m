From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: small skb_segment() cleanup
Date: Fri, 17 May 2013 10:27:46 -0700
Message-ID: <1368811666.3301.111.camel@edumazet-glaptop>
References: <1368810804.3301.100.camel@edumazet-glaptop>
	 <CAHLZz11hoXDQ3ie2jBnfpQG7+SqgCuNMBA087ms3M+OPtnhqKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:40106 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756364Ab3EQR1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 13:27:47 -0400
Received: by mail-pb0-f50.google.com with SMTP id wy17so550933pbc.9
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 10:27:47 -0700 (PDT)
In-Reply-To: <CAHLZz11hoXDQ3ie2jBnfpQG7+SqgCuNMBA087ms3M+OPtnhqKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 10:20 -0700, Harvey Harrison wrote:
> On Fri, May 17, 2013 at 10:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> 
> 
> > @@ -2817,7 +2817,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
> >
> >                         nskb->truesize += skb_end_offset(nskb) - hsize;
> >                         skb_release_head_state(nskb);
> > -                       __skb_push(nskb, doffset);
> 
> is __skb_push equivalent to __skb_put?

Doh... right you are !
