From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Tue, 6 Jul 2004 09:21:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705232141.GA9939@gondor.apana.org.au>
References: <20040703095215.GA16195@gondor.apana.org.au> <20040705161148.503722e7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040705161148.503722e7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jul 05, 2004 at 04:11:48PM -0700, David S. Miller wrote:
> 
> > I'd like to add two new xfrm_user messages, FLUSHSA and FLUSHPOLICY.
> > 
> > I've cleaned up the existing MSG definitions by converting them to
> > an enum.  This should make future additions slightly easier in that
> > XFRM_MSG_MAX won't have to be touched again.
> 
> If we end up needing the define macros anyways, after that discussion
> with Yoshifuji, I don't see the point to this change any more and
> therefore I'm not going to apply it.

The point is that with enums we won't have to change XFRM_MSG_MAX
every time a new message type is added.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
