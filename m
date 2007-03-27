From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 2/2] [SK_BUFF]: Introduce skb_copy_from_linear_data{_offset}
Date: Tue, 27 Mar 2007 18:22:14 -0300
Message-ID: <39e6f6c70703271422i3881fc6bw18480e8f1b553e27@mail.gmail.com>
References: <20070327194148.GC20303@ghostprotocols.net>
	 <20070327.140749.106434705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:14815 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965453AbXC0VWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:22:17 -0400
Received: by ug-out-1314.google.com with SMTP id 44so20720uga
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 14:22:15 -0700 (PDT)
In-Reply-To: <20070327.140749.106434705.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/27/07, David Miller <davem@davemloft.net> wrote:
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Tue, 27 Mar 2007 16:41:48 -0300
>
> > +static inline void skb_move_linear_data(const struct sk_buff *skb,
> > +                                     const int from_offset,
> > +                                     const int to_offset,
> > +                                     const unsigned int len)
> > +{
> > +     memcpy(skb->data + to_offset, skb->data + from_offset, len);
> > +}
> > +
>
> What do you intend to use this for?  There are no users in
> your patch, and I'd be fearful of overlapping cases (which
> ought to be common for anything using this) which therefore
> would require use of memmove() instead of memcpy().
>
> How about we just leave out interfaces until we have a use
> case?

I don't want to intend anything with this, was just a brain fart, a
failed attempt to convince me that this was needed, I apologise for
letting this sleep thru, will remove and resubmit, ok?

- Arnaldo
