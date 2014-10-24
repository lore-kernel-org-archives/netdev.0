From: Florian Westphal <fw@strlen.de>
Subject: Re: bridge: Do not compile options in br_parse_ip_options
Date: Fri, 24 Oct 2014 12:41:49 +0200
Message-ID: <20141024104149.GA7401@breakpoint.cc>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
 <20141004100413.GA1241@breakpoint.cc>
 <20141004135508.GA10705@gondor.apana.org.au>
 <20141004141802.GA10878@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	bsd@redhat.com, stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51710 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756104AbaJXKmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 06:42:05 -0400
Content-Disposition: inline
In-Reply-To: <20141004141802.GA10878@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> bridge: Do not compile options in br_parse_ip_options
> 
> Commit 462fb2af9788a82a534f8184abfde31574e1cfa0
> 
> 	bridge : Sanitize skb before it enters the IP stack
> 
> broke when IP options are actually used because it mangles the
> skb as if it entered the IP stack which is wrong because the
> bridge is supposed to operate below the IP stack.
> 
> Since nobody has actually requested for parsing of IP options
> this patch fixes it by simply reverting to the previous approach
> of ignoring all IP options, i.e., zeroing the IPCB.
> 
> If and when somebody who uses IP options and actually needs them
> to be parsed by the bridge complains then we can revisit this.
> 
> Reported-by: David Newall <davidn@davidnewall.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Tested-by: Florian Westphal <fw@strlen.de>

Pablo, could you please apply this?

Thanks!
