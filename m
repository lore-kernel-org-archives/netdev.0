From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV6: convert /proc/net/igmp6 to seq_file
Date: Tue, 1 Jul 2003 14:41:19 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307011439520.26681-100000@excalibur.intercode.com.au>
References: <20030701.132315.11621908.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030701.132315.11621908.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> Really???? 
> I had compiled it before I sent the patch and I can compile it now.
> How did you fail to compile it?

net/ipv6/mcast.c: In function `igmp6_mc_seq_stop':
net/ipv6/mcast.c:2124: invalid type argument of `->'
make[2]: *** [net/ipv6/mcast.o] Error 1
make[1]: *** [net/ipv6] Error 2
make: *** [net] Error 2


read_unlock_bh(state->idev->lock) should be 
read_unlock_bh(&state->idev->lock)


At least one of the other patches has a similar problem.



- James
-- 
James Morris
<jmorris@intercode.com.au>
