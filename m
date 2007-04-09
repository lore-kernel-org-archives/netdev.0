From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: esp: fix skb_tail_pointer conversion bug
Date: Mon, 09 Apr 2007 11:46:30 -0700 (PDT)
Message-ID: <20070409.114630.27927768.davem@davemloft.net>
References: <461886F6.1010308@trash.net>
	<39e6f6c70704080607u729e72bbq4ac5fddfe144ef18@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752864AbXDISqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:46:31 -0400
In-Reply-To: <39e6f6c70704080607u729e72bbq4ac5fddfe144ef18@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sun, 8 Apr 2007 10:07:29 -0300

> On 4/8/07, Patrick McHardy <kaber@trash.net> wrote:
> >
> > [XFRM]: esp: fix skb_tail_pointer conversion bug
> >
> > Fix incorrect switch of "trailer" skb by "skb" during skb_tail_pointer
> > conversion:
> >
> > -       *(u8*)(trailer->tail - 1) = top_iph->protocol;
> > +       *(skb_tail_pointer(skb) - 1) = top_iph->protocol;
> >
> > -       *(u8 *)(trailer->tail - 1) = *skb_network_header(skb);
> > +       *(skb_tail_pointer(skb) - 1) = *skb_network_header(skb);
> >
> >
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied, thanks everyone.
