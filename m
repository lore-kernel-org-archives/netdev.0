From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 09:13:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616231317.GA5742@gondor.apana.org.au>
References: <20040615124334.GA25164@gondor.apana.org.au> <20040616195653.GC29781@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040616195653.GC29781@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 11:56:53PM +0400, Alexey Kuznetsov wrote:
> 
> Each SA bundle referring to a dst has pmtu derived from pmtu
> of that dst. So, actually, I do not understand the question.
> If the policy uses the raw IP level path dst, it inherits this pmtu.

The problem is that each bundle can have only one PMTU.  But
there can be an arbitrary number of paths over each bundle.

> ... while talking to arnor.apana.org.au.:
> >>> RCPT To:<herbert@gondor.apana.org.au>
> <<< 550 mail from 194.67.69.111 rejected: administrative prohibition

Sorry, should be fixed now.
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
