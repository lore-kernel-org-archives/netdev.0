From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: is sk->reuse truly a boolean?
Date: Tue, 20 May 2003 14:08:36 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520170836.GH801@conectiva.com.br>
References: <20030520162906.GF801@conectiva.com.br> <20030521.015317.125867074.yoshfuji@linux-ipv6.org> <20030520165831.GG801@conectiva.com.br> <20030521.020242.16237776.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030521.020242.16237776.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 21, 2003 at 02:02:42AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
> In article <20030520165831.GG801@conectiva.com.br> (at Tue, 20 May 2003 13:58:31 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:
> 
> > > I don't think so.  Above modification will break current 
> > > reasonable bind(2) behavior.
> > > 
> > > Well, it would be dead code, which would be used for (still 
> > > unsupported) SO_REUSEPORT.
> > 
> > So just delete the test?
> 
> Hmm, (bacause I want to remember this path in the code,) how about #if 0 ?
> David?

Sounds good to me.
