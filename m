From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [TCP] Show all SYN_RECV sockets in /proc/net/tcp
Date: Tue, 5 Oct 2004 20:58:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005205844.444dc66a.rddunlap@osdl.org>
References: <416355BD.50402@conectiva.com.br>
	<E1CF1eo-0003qW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CF1eo-0003qW-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 06 Oct 2004 12:35:58 +1000 Herbert Xu wrote:

| Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
| > 
| > Go ahead and do it with the current seq_file infrastructure 8) Standard
| 
| Does the current seq_file infrastructure offer anything new compared
| to what's in the existing /proc/net/tcp code?
| 
| > answer for these cases is remove /proc/net/tcp altogether and convert
| > the userland tools to use netlink instead.
| 
| Completely agreed.  As I said I only started looking at this because
| I was trying to fix tcp_diag.

Dave's other standard answer is "don't mess up the userland API",
including /proc interfaces.  (not to put words into Dave's mouth)

--
~Randy
