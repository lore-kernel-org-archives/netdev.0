From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch 4/5] net/ipv6/ip6_flowlabel.c: copy_to_user return code
Date: Mon, 07 Mar 2005 07:38:43 +0900 (JST)
Message-ID: <20050307.073843.09980515.yoshfuji@linux-ipv6.org>
References: <20050306222118.401D11ED3D@trashy.coderock.org>
	<20050307.073213.32943613.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@oss.sgi.com, yrgrknmxpzlk@gawab.com,
        yoshfuji@linux-ipv6.org
To: domen@coderock.org
In-Reply-To: <20050307.073213.32943613.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050307.073213.32943613.yoshfuji@linux-ipv6.org> (at Mon, 07 Mar 2005 07:32:13 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20050306222118.401D11ED3D@trashy.coderock.org> (at Sun, 06 Mar 2005 23:21:17 +0100), domen@coderock.org says:
> 
> > 
> > compile warning cleanup - handle copy_to/from_user error 
> > returns
> 
> Wrong. You introduce a leak.

Ah, sorry, not really, but I still think it is wrong:
fl_intern() insert it to hash, and
then you freed up the memory.
I believe this is wrong.

--yoshfuji
