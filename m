From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [TCP] Show all SYN_RECV sockets in /proc/net/tcp
Date: Tue, 05 Oct 2004 23:43:49 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41635BE5.2000302@conectiva.com.br>
References: <E1CF1eo-0003qW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CF1eo-0003qW-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Herbert Xu wrote:
> Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
> 
>>Go ahead and do it with the current seq_file infrastructure 8) Standard
> 
> 
> Does the current seq_file infrastructure offer anything new compared
> to what's in the existing /proc/net/tcp code?

Haven't checked, it has been a long time already since I wrote that
spaguetti code to fit the seq_file infrastructure :)

>>answer for these cases is remove /proc/net/tcp altogether and convert
>>the userland tools to use netlink instead. 
> 
> Completely agreed.  As I said I only started looking at this because
> I was trying to fix tcp_diag.

I see, and thank you for getting so involved in linux networking
development, you're doing a wonderful work :-)

- Arnaldo
