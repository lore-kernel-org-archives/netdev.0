From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: IPsec and Path MTU
Date: Wed, 16 Jun 2004 23:56:53 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616195653.GC29781@ms2.inr.ac.ru>
References: <20040615124334.GA25164@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040615124334.GA25164@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> As it is, the MTU for any peer with an IPsec policy is determined
> by the MTU of its dst->path.  But this is wrong because it assigns
> a single MTU to all hosts behind an IPsec gateway, even though their
> paths may well diverge beyond the gateway.

Each SA bundle referring to a dst has pmtu derived from pmtu
of that dst. So, actually, I do not understand the question.
If the policy uses the raw IP level path dst, it inherits this pmtu.

Alexey


PS. Broadcast: guys, please, tell someone to Herbert, my e-mail is banned
at his server:

... while talking to arnor.apana.org.au.:
>>> RCPT To:<herbert@gondor.apana.org.au>
<<< 550 mail from 194.67.69.111 rejected: administrative prohibition
