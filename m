From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: is sk->reuse truly a boolean?
Date: Wed, 21 May 2003 02:02:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.020242.16237776.yoshfuji@linux-ipv6.org>
References: <20030520162906.GF801@conectiva.com.br>
	<20030521.015317.125867074.yoshfuji@linux-ipv6.org>
	<20030520165831.GG801@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030520165831.GG801@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030520165831.GG801@conectiva.com.br> (at Tue, 20 May 2003 13:58:31 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:

> > I don't think so.  Above modification will break current 
> > reasonable bind(2) behavior.
> > 
> > Well, it would be dead code, which would be used for (still 
> > unsupported) SO_REUSEPORT.
> 
> So just delete the test?

Hmm, (bacause I want to remember this path in the code,) how about #if 0 ?
David?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
