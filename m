From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: is sk->reuse truly a boolean?
Date: Tue, 20 May 2003 13:58:31 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520165831.GG801@conectiva.com.br>
References: <20030520155744.GE801@conectiva.com.br> <20030521.011520.49126007.yoshfuji@linux-ipv6.org> <20030520162906.GF801@conectiva.com.br> <20030521.015317.125867074.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030521.015317.125867074.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 21, 2003 at 01:53:17AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
> In article <20030520162906.GF801@conectiva.com.br> (at Tue, 20 May 2003 13:29:07 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:
> 
> > > > In net/core/sock.c, setsockopt it just assigns 1 or 0, i.e. if userspace
> > > > passes > 1 it becomes 1, is this the intended behaviour? I think we have a 
> > > > bug in tcp_ipv4 or in core/sock.c 8)
> > > 
> > > Good point. However, SO_REUSEADDR works because we have tcp_bind_conflict().
> > 
> > mmmkay, so we have to fix it by changing the test to:
> > 
> > 		    if (sk->reuse)
> > 			   goto success;
> > 
> > Isn't it?
> 
> I don't think so.  Above modification will break current 
> reasonable bind(2) behavior.
> 
> Well, it would be dead code, which would be used for (still 
> unsupported) SO_REUSEPORT.

So just delete the test?

- Arnaldo
