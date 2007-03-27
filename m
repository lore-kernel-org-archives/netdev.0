From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [SK_BUFF]: Introduce
 skb_copy_from_linear_data{_offset}
Date: Tue, 27 Mar 2007 15:31:09 -0700 (PDT)
Message-ID: <20070327.153109.91000136.davem@davemloft.net>
References: <20070327194148.GC20303@ghostprotocols.net>
	<20070327.140749.106434705.davem@davemloft.net>
	<39e6f6c70703271456s24752059h4e3c4f40d7aad51e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934230AbXC0WbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 18:31:10 -0400
In-Reply-To: <39e6f6c70703271456s24752059h4e3c4f40d7aad51e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 27 Mar 2007 18:56:11 -0300

> On 3/27/07, David Miller <davem@davemloft.net> wrote:
> > From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> > Date: Tue, 27 Mar 2007 16:41:48 -0300
> >
> > > +static inline void skb_move_linear_data(const struct sk_buff *skb,
> > > +                                     const int from_offset,
> > > +                                     const int to_offset,
> > > +                                     const unsigned int len)
> > > +{
> > > +     memcpy(skb->data + to_offset, skb->data + from_offset, len);
> > > +}
> > > +
> >
> > What do you intend to use this for?  There are no users in
> > your patch, and I'd be fearful of overlapping cases (which
> > ought to be common for anything using this) which therefore
> > would require use of memmove() instead of memcpy().
> >
> > How about we just leave out interfaces until we have a use
> > case?
> 
> It should be ok now, please take a look in a throwaway branch to make
> sure, sorry for the disturbance.

Where should I pull from?  Please always specify this, I delete
old emails from a thread when I expect a resubmit, so I don't
even know the original URL.  THanks.
