From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Sat, 03 Jul 2004 19:04:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703.190434.119517848.yoshfuji@linux-ipv6.org>
References: <20040703095215.GA16195@gondor.apana.org.au>
	<20040703.190042.70899669.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20040703.190042.70899669.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

To clarify:

In article <20040703.190042.70899669.yoshfuji@linux-ipv6.org> (at Sat, 03 Jul 2004 19:00:42 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> > I've cleaned up the existing MSG definitions by converting them to
> > an enum.  This should make future additions slightly easier in that
> > XFRM_MSG_MAX won't have to be touched again.
:
> Well, I think we'd better to do
> 
>  #define XFRM_MSG_GETSA XFRM_MSG_GETSA
> 
> etc. because this would break (future) applications which do
> #ifdef.

I meant, the change (without #define) would break (future) applications 
which do #ifdef.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
