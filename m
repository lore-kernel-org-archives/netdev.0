From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [patch] clean up tcp_sk(), 2.6.0
Date: Tue, 30 Dec 2003 14:57:52 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031230165751.GH28868@conectiva.com.br>
References: <20031230163230.GA12553@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20031230163230.GA12553@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Dec 30, 2003 at 05:32:30PM +0100, Ingo Molnar escreveu:
> 
> i recently wasted a few hours on a bug where i used "tcp_sk(sock)"
> instead of "tcp_sk(sock->sk)" - the former, while being blatantly
> incorrect, compiles just fine on 2.6.0. The patch below is equivalent to
> the define but is also type-safe. Compiles cleanly & boots fine on
> 2.6.0.

Don't have a problem, but then it'd be nice to do this for udp_sk, raw_sk,
etc, etc :)
 
- Arnaldo
