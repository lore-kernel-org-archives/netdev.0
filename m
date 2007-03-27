From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 2/2] [SK_BUFF]: Introduce skb_copy_from_linear_data{_offset}
Date: Tue, 27 Mar 2007 18:56:11 -0300
Message-ID: <39e6f6c70703271456s24752059h4e3c4f40d7aad51e@mail.gmail.com>
References: <20070327194148.GC20303@ghostprotocols.net>
	 <20070327.140749.106434705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:28094 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932966AbXC0V4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:56:12 -0400
Received: by nz-out-0506.google.com with SMTP id s1so2560304nze
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 14:56:12 -0700 (PDT)
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

It should be ok now, please take a look in a throwaway branch to make
sure, sorry for the disturbance.

- Arnaldo
