From: "David S. Miller" <davem@davemloft.net>
Subject: Re: build breakage
Date: Mon, 7 Mar 2005 09:34:33 -0800
Message-ID: <20050307093433.3b3270b0.davem@davemloft.net>
References: <422C09FD.3000702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <422C09FD.3000702@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 07 Mar 2005 02:59:57 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Upstream net changes caused this to appear..
> 
>    CC      drivers/net/appletalk/cops.o
> In file included from drivers/net/appletalk/cops.c:70:
> include/linux/atalk.h:67: error: field `sk' has incomplete type
> make[3]: *** [drivers/net/appletalk/cops.o] Error 1
> make[2]: *** [drivers/net/appletalk] Error 2

atalk.h needs net/sock.h, I've just applied a patch from
Andrew Morton fixing exactly that.

Thanks.
