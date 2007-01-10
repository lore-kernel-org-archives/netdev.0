From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Thu, 11 Jan 2007 07:49:22 +1100
Message-ID: <20070110204922.GA1652@gondor.apana.org.au>
References: <Pine.LNX.4.64.0701100913050.8582@d.namei> <001301c734de$8252b170$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'James Morris' <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1799 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965028AbXAJUuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 15:50:07 -0500
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
Content-Disposition: inline
In-Reply-To: <001301c734de$8252b170$cc0a010a@tcssec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 11:41:07AM -0600, Venkat Yekkirala wrote:
> 
> Only, on a security policy denial (-ESRCH from the LSM hook), a 0
> is returned by the resolver to signify no applicable policy since
> a negative result is akin to no policy. And I see the "no policy"
> case is already cached.

I'm not talking about an xfrm policy lookup failure, that exists
with or without SELinux.  I'm talking about an error returned from
security_xfrm_policy_lookup(), i.e., whether a policy can be used
or not.  For that case, we only cache positive results currently.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
