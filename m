From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [TCP] Show all SYN_RECV sockets in /proc/net/tcp
Date: Wed, 06 Oct 2004 11:55:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006.115517.130604805.yoshfuji@linux-ipv6.org>
References: <20041006020650.GA14583@gondor.apana.org.au>
	<416355BD.50402@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <416355BD.50402@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <416355BD.50402@conectiva.com.br> (at Tue, 05 Oct 2004 23:17:33 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:

> > I found that /proc/net/tcp didn't do it correctly either.  So here is
> > a small patch to fix /proc/net/tcp.
> > 
> > The logic in there stinks though so I'd love to see a rewrite.
> 
> Go ahead and do it with the current seq_file infrastructure 8) Standard
> answer for these cases is remove /proc/net/tcp altogether and convert
> the userland tools to use netlink instead.

It is okay to have dual interface (procfs and netlink), but
please, please do not remove /proc/net/tcp (during 2.6.x at least).
And, yes, if you want to add something, it should be done in netlink.

Thanks.

--yoshfuji
