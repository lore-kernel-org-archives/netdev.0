From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: build breakage
Date: Mon, 7 Mar 2005 14:52:31 -0300
Message-ID: <20050307175231.GB28841@conectiva.com.br>
References: <422C09FD.3000702@pobox.com> <20050307093433.3b3270b0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050307093433.3b3270b0.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Mar 07, 2005 at 09:34:33AM -0800, David S. Miller escreveu:
> On Mon, 07 Mar 2005 02:59:57 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > Upstream net changes caused this to appear..
> > 
> >    CC      drivers/net/appletalk/cops.o
> > In file included from drivers/net/appletalk/cops.c:70:
> > include/linux/atalk.h:67: error: field `sk' has incomplete type
> > make[3]: *** [drivers/net/appletalk/cops.o] Error 1
> > make[2]: *** [drivers/net/appletalk] Error 2
> 
> atalk.h needs net/sock.h, I've just applied a patch from
> Andrew Morton fixing exactly that.
> 
> Thanks.

Thanks, I wonder how this one slipped in unnoticed... :-\
