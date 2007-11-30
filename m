From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: wireless vs. alignment requirements
Date: Fri, 30 Nov 2007 11:26:21 +1100
Message-ID: <20071130002621.GI23769@gondor.apana.org.au>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <4748855C.5090103@linux-foundation.org> <474C50D7.5010901@zytor.com> <20071129131107.GC8487@gondor.apana.org.au> <474EFBEB.5000804@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2775 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762831AbXK3A11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 19:27:27 -0500
Content-Disposition: inline
In-Reply-To: <474EFBEB.5000804@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 09:50:35AM -0800, H. Peter Anvin wrote:
>
> Uhm, most cards affected *ARE* Ethernet cards, due to the bloody 14-byte 
> header.

Well most Ethernet drivers are using NET_IP_ALIGN which means that IP
stack gets aligned packets only.

sky2 is the exception here, not the rule.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
