From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: convert /proc/net/igmp6 to seq_file
Date: Tue, 01 Jul 2003 14:29:47 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.142947.75158018.yoshfuji@linux-ipv6.org>
References: <20030701.132315.11621908.yoshfuji@linux-ipv6.org>
	<Mutt.LNX.4.44.0307011439520.26681-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0307011439520.26681-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Mutt.LNX.4.44.0307011439520.26681-100000@excalibur.intercode.com.au> (at Tue, 1 Jul 2003 14:41:19 +1000 (EST)), James Morris <jmorris@intercode.com.au> says:

> net/ipv6/mcast.c: In function `igmp6_mc_seq_stop':
> net/ipv6/mcast.c:2124: invalid type argument of `->'
> make[2]: *** [net/ipv6/mcast.o] Error 1
> make[1]: *** [net/ipv6] Error 2
> make: *** [net] Error 2
> 
> 
> read_unlock_bh(state->idev->lock) should be 
> read_unlock_bh(&state->idev->lock)
> 
> 
> At least one of the other patches has a similar problem.

Hmm..., I don't understand why I could compile it...
Okay, I'll resend the patches.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
