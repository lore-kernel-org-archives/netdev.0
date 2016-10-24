From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] macsec: Fix header length if SCI is added if
 explicitily disabled
Date: Mon, 24 Oct 2016 15:38:57 +0200
Message-ID: <20161024133857.GA21117@bistromath.localdomain>
References: <bfb9f7ef-39b1-269f-48de-d7caf5c54c2f@strongswan.org>
 <20161024112822.GA28497@bistromath.localdomain>
 <253edab5-98e6-60e0-0c29-2f1205a4dd1a@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938957AbcJXNjB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 09:39:01 -0400
Content-Disposition: inline
In-Reply-To: <253edab5-98e6-60e0-0c29-2f1205a4dd1a@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-10-24, 15:32:40 +0200, Tobias Brunner wrote:
> > [snip]
> >> @@ -440,12 +448,12 @@ static void macsec_fill_sectag(struct macsec_eth_header *h,
> >>  			       const struct macsec_secy *secy, u32 pn)
> >>  {
> >>  	const struct macsec_tx_sc *tx_sc = &secy->tx_sc;
> >> +	bool sci_present = send_sci(secy);
> > 
> > You're already computing this in macsec_encrypt() just before calling
> > macsec_fill_sectag(), so you could pass it as argument instead of
> > recomputing it.
> 
> Right, I'll send a v2.  Would you like me to inline the send_sci()
> function, as it will only be called once afterwards.

I think keeping the send_sci() function is okay, but if you prefer to
inline it, I don't mind.

-- 
Sabrina
