From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Sat, 03 Jul 2004 19:00:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703.190042.70899669.yoshfuji@linux-ipv6.org>
References: <20040703095215.GA16195@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20040703095215.GA16195@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040703095215.GA16195@gondor.apana.org.au> (at Sat, 3 Jul 2004 19:52:15 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> I've cleaned up the existing MSG definitions by converting them to
> an enum.  This should make future additions slightly easier in that
> XFRM_MSG_MAX won't have to be touched again.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Well, I think we'd better to do

 #define XFRM_MSG_GETSA XFRM_MSG_GETSA

etc. because this would break (future) applications which do
#ifdef.

--yoshfuji
