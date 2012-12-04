From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] bridge: implement multicast fast leave
Date: Tue, 4 Dec 2012 09:38:38 +0800
Message-ID: <20121204013838.GA31329@gondor.apana.org.au>
References: <1354545363-11953-1-git-send-email-amwang@redhat.com>
 <20121203075316.0b1da39d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:35967 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751211Ab2LDBip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 20:38:45 -0500
Content-Disposition: inline
In-Reply-To: <20121203075316.0b1da39d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2012 at 07:53:16AM -0800, Stephen Hemminger wrote:
> On Mon,  3 Dec 2012 22:36:03 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > Fast leave allows bridge to immediately stops the multicast
> > traffic on the port receives IGMP Leave when IGMP snooping is enabled,
> > no timeouts are observed.
> > 
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: Stephen Hemminger <shemminger@vyatta.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> I like the feature, and it looks like an oversight in the initial design.
> Why is this not the default, adding more options obscures it.

If the port has a bridge on it then you're toast.  I think this
should be a per-port option.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
