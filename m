From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V3 1/3] net: adjust napi_consume_skb to handle
 none-NAPI callers
Date: Fri, 11 Mar 2016 08:45:49 +0100
Message-ID: <20160311084549.1b011723@redhat.com>
References: <20160310145803.22901.24734.stgit@firesoul>
	<20160310145911.22901.28762.stgit@firesoul>
	<56E1AD33.3020507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	gerlitz.or@gmail.com, brouer@redhat.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934008AbcCKHp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 02:45:58 -0500
In-Reply-To: <56E1AD33.3020507@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 10 Mar 2016 20:21:55 +0300
Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -801,9 +801,9 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
> >   	if (unlikely(!skb))
> >   		return;
> >
> > -	/* if budget is 0 assume netpoll w/ IRQs disabled */
> > +	/* Zero budget indicate none-NAPI context called us, like netpoll */  
> 
>     Non-NAPI?

Okay, I'll send a V4.  Hope there are no more nitpicking changes...
I'll also adjust the subj none-NAPI -> non-NAPI, and hope that does not
disturb patchwork.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
