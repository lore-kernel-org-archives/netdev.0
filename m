From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [INET] Add flags field to ip_tunnel_parm
Date: Tue, 14 Sep 2004 21:52:05 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914.215205.110659321.yoshfuji@linux-ipv6.org>
References: <20040914121617.GA5652@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20040914121617.GA5652@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040914121617.GA5652@gondor.apana.org.au> (at Tue, 14 Sep 2004 22:16:17 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> BTW if anyone else wants to add more fields to the structure, now is
> the time.

Well, you simply cannot do this.

Kernel will get garbage from old binaries,
and kernel will break user space if it tries 
to get params into old structure.

So, please change SIOxxxTUNNEL values to support both interfaces
(or give up ioctl and use rtnetlink instead!)

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
