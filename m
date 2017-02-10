From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next 5/5] esp: Add a software GRO codepath
Date: Fri, 10 Feb 2017 08:39:18 +0100
Message-ID: <20170210073917.GB30338@gauss.secunet.com>
References: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
 <1486458851-4920-6-git-send-email-steffen.klassert@secunet.com>
 <20170208.131956.1793646962232036920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
        <sowmini.varadhan@oracle.com>, <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47076 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751026AbdBJHjn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 02:39:43 -0500
Content-Disposition: inline
In-Reply-To: <20170208.131956.1793646962232036920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 01:19:56PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 7 Feb 2017 10:14:11 +0100
> 
> > +static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
> > +					 struct sk_buff *skb)
> > +{
> > +	int err;
> > +	__be32 seq;
> > +	__be32 spi;
> > +	struct xfrm_state *x;
> > +	int offset = skb_gro_offset(skb);
> 
> Please order local variable declarations from longest to shortest.

No problem, will do.

Thanks for looking over it!
