From: "David S. Miller" <davem@redhat.com>
Subject: Re: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Mon, 5 Jul 2004 16:11:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705161148.503722e7.davem@redhat.com>
References: <20040703095215.GA16195@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040703095215.GA16195@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 3 Jul 2004 19:52:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I'd like to add two new xfrm_user messages, FLUSHSA and FLUSHPOLICY.
> 
> I've cleaned up the existing MSG definitions by converting them to
> an enum.  This should make future additions slightly easier in that
> XFRM_MSG_MAX won't have to be touched again.

If we end up needing the define macros anyways, after that discussion
with Yoshifuji, I don't see the point to this change any more and
therefore I'm not going to apply it.
