From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next PATCH v4 2/3] net: TCP thin linear timeouts
Date: Thu, 18 Feb 2010 10:41:57 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002181040520.9961@melkinpaasi.cs.helsinki.fi>
References: <4B7AAE69.8020701@simula.no> <20100217.163255.133898079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	hannemann@nets.rwth-aachen.de, LKML <linux-kernel@vger.kernel.org>,
	shemminger@vyatta.com, william.allen.simpson@gmail.com,
	damian@tvk.rwth-aachen.de, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: apetlund@simula.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58558 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab0BRIl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 03:41:59 -0500
In-Reply-To: <20100217.163255.133898079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Feb 2010, David Miller wrote:

> From: Andreas Petlund <apetlund@simula.no>
> Date: Tue, 16 Feb 2010 15:40:41 +0100
> 
> > @@ -341,6 +342,8 @@ struct tcp_sock {
> >  	u16	advmss;		/* Advertised MSS			*/
> >  	u8	frto_counter;	/* Number of new acks after RTO */
> >  	u8	nonagle;	/* Disable Nagle algorithm?             */
> > +	u8      thin_lto    : 1,/* Use linear timeouts for thin streams */
> > +		thin_undef  : 7;
> >  
> 
> There is now a gap of 3 unused bytes here in this critical
> core TCP socket data structure.
> 
> Please either find a way to avoid this hole, or document
> it with a comment.

There would be multiple bits free for use in both frto_counter and nonagle 
byte.

-- 
 i.
