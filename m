From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: is sk->reuse truly a boolean?
Date: Wed, 21 May 2003 01:15:20 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.011520.49126007.yoshfuji@linux-ipv6.org>
References: <20030520155744.GE801@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030520155744.GE801@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030520155744.GE801@conectiva.com.br> (at Tue, 20 May 2003 12:57:45 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:

> From what I see in the code and from references in, for instance, Unix
> Network Programming (W. Richard Stevens) it is, but then how can this work?
> 
> net/ipv4/tcp_ipv4.c, line 265
> 
>                 if (sk->reuse > 1)
>                         goto success;
> 
> In net/core/sock.c, setsockopt it just assigns 1 or 0, i.e. if userspace
> passes > 1 it becomes 1, is this the intended behaviour? I think we have a 
> bug in tcp_ipv4 or in core/sock.c 8)

Good point. However, SO_REUSEADDR works because we have tcp_bind_conflict().

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
