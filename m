From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: Re: [PATCH net-next v3] packet: uses kfree_skb() for errors.
Date: Thu, 14 Apr 2016 14:11:48 -0700
Message-ID: <20160414211147.GA15463@jwg>
References: <1460132748-23561-1-git-send-email-weongyo.linux@gmail.com>
 <20160413.225601.721902514935757078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36244 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbcDNVLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 17:11:50 -0400
Received: by mail-pa0-f66.google.com with SMTP id k3so7658307pav.3
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 14:11:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160413.225601.721902514935757078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 10:56:01PM -0400, David Miller wrote:
> From: Weongyo Jeong <weongyo.linux@gmail.com>
> Date: Fri,  8 Apr 2016 09:25:48 -0700
> 
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 1ecfa71..4e054bb 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -2042,6 +2042,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
> >  	u8 *skb_head = skb->data;
> >  	int skb_len = skb->len;
> >  	unsigned int snaplen, res;
> > +	bool err = false;
> >  
> >  	if (skb->pkt_type == PACKET_LOOPBACK)
> >  		goto drop;
> 
> It is non-canonical to use a variable named 'err' as a boolean.
> Instead, all programmers expect a variable named 'err' to be an
> integer type and to hold an error code.
> 
> Therefore please use a more appropriate name for this variable.
> 
> Name it in a way which describes the exact important condition
> which is true or false.
> 
> Thank you.

Thank you for your opinion.  I'd fixed it to proper name and
submitted v4 patch.

Regards,
Weongyo Jeong
