From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fixing the cases where tcp_tw_bucket was accessed as a
 sock
Date: Wed, 15 Oct 2003 22:10:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015221020.098f9779.davem@redhat.com>
References: <20031012131344.GH16182@conectiva.com.br>
	<20031013124930.0e75a325.davem@redhat.com>
	<20031015113648.GD1174@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20031015113648.GD1174@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 08:36:48 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Em Mon, Oct 13, 2003 at 12:49:30PM -0700, David S. Miller escreveu:
> > Let's do one thing at a time.  First, fix the original bug
> > in tcp_ipv4.c by just putting your inet_rcv_saddr() shorthand
> > right there in tcp_ipv4.c and name it tcp4_rcv_saddr() or
> > something like that.
 ... 
> :) Here is the first part:

Perfect, patch applied.

Thanks.
