From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Wed, 26 Mar 2008 12:47:31 +0200
Message-ID: <200803261247.31210.joakim.koskela@hiit.fi>
References: <200803261115.26157.joakim.koskela@hiit.fi> <47EA13DA.7070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Komu Miika <Miika.Komu@hiit.fi>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:58551 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbYCZKqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 06:46:34 -0400
In-Reply-To: <47EA13DA.7070708@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 March 2008 11:14, Patrick McHardy wrote:
> Joakim Koskela wrote:
> > diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
> > index 091e670..20d214f 100644
> > --- a/net/ipv4/esp4.c
> > +++ b/net/ipv4/esp4.c
> > @@ -404,7 +404,8 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int
> > mtu) break;
> >  	case XFRM_MODE_BEET:
> >  		/* The worst case. */
> > -		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
> > +		/* This will be seen to in the esp header_len */
> > +		/* mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem); */
> >  		break;
> >  	}
>
> Why are you disabling this?

Thanks - can't remember and doesn't seem necessary. I'll reverse that.
