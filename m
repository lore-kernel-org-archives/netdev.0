From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] IPV6: use ipv6_addr_any()
Date: Wed, 28 Jan 2004 20:29:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128.202955.118179192.yoshfuji@linux-ipv6.org>
References: <20040128.163043.120256112.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0401281256260.21205-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0401281256260.21205-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0401281256260.21205-100000@netcore.fi> (at Wed, 28 Jan 2004 12:57:27 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> On Wed, 28 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> > Use simple ipv6_addr_any()
> > where ipv6_addr_type() is called only to check for unspecified address.
> 
> Speakign of which, should it be better to change this to _unspecified
> if we're changing this as one could be led to believe that "any"  
> refers to "any IPv6 address" which is obviously not the case.

I don't think we need to change the name for now.
It however should be done by another patch 
if it is better to be changed.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
