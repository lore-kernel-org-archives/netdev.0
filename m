From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Sat, 07 Feb 2004 15:46:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207.154603.51160771.yoshfuji@linux-ipv6.org>
References: <20040207.142519.117436499.yoshfuji@linux-ipv6.org>
	<OF92ABDC1A.4056C324-ON88256E33.002267FA-88256E33.00247258@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF92ABDC1A.4056C324-ON88256E33.002267FA-88256E33.00247258@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF92ABDC1A.4056C324-ON88256E33.002267FA-88256E33.00247258@us.ibm.com> (at Fri, 6 Feb 2004 22:40:42 -0800), David Stevens <dlstevens@us.ibm.com> says:

> Good idea; I'll incorporate all the comments, retest and repost.
> 
> > So... hmm... Let's check dev->flags ^ (IFF_PROMISC|IFF_ALLMULTI) like
> this.
> 
>       I think you mean (dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) here,
> right?

Oops! Sorry, you're right...
And, it'd be good to use unlikely() here.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
