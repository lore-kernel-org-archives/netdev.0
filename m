From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [TCP] Show all SYN_RECV sockets in /proc/net/tcp
Date: Tue, 05 Oct 2004 23:17:33 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416355BD.50402@conectiva.com.br>
References: <20041006020650.GA14583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041006020650.GA14583@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Herbert Xu wrote:
> Hi Dave:
> 
> I was fixing the tcp_diag so that it shows SYN_RECV sockets properly.
> I found that /proc/net/tcp didn't do it correctly either.  So here is
> a small patch to fix /proc/net/tcp.
> 
> The logic in there stinks though so I'd love to see a rewrite.

Go ahead and do it with the current seq_file infrastructure 8) Standard
answer for these cases is remove /proc/net/tcp altogether and convert
the userland tools to use netlink instead.

- Arnaldo
