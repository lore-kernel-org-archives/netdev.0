From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4 2/3] net: TCP thin linear timeouts
Date: Wed, 17 Feb 2010 16:32:55 -0800 (PST)
Message-ID: <20100217.163255.133898079.davem@davemloft.net>
References: <4B7AAE69.8020701@simula.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de,
	ebiederm@xmission.com
To: apetlund@simula.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60261
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753355Ab0BRAck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 19:32:40 -0500
In-Reply-To: <4B7AAE69.8020701@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Petlund <apetlund@simula.no>
Date: Tue, 16 Feb 2010 15:40:41 +0100

> @@ -341,6 +342,8 @@ struct tcp_sock {
>  	u16	advmss;		/* Advertised MSS			*/
>  	u8	frto_counter;	/* Number of new acks after RTO */
>  	u8	nonagle;	/* Disable Nagle algorithm?             */
> +	u8      thin_lto    : 1,/* Use linear timeouts for thin streams */
> +		thin_undef  : 7;
>  

There is now a gap of 3 unused bytes here in this critical
core TCP socket data structure.

Please either find a way to avoid this hole, or document
it with a comment.
