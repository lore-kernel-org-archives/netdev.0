From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: 2.6.0: something is leaking memory
Date: Tue, 6 Jan 2004 17:03:58 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040106190358.GV28868@conectiva.com.br>
References: <slrnbvgohn.1pb.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041257290.2162@home.osdl.org> <slrnbvh1hd.jl6.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041826400.2162@home.osdl.org> <20040104204834.40b6ca51.davem@redhat.com> <20040106155933.GA3373@bender.home.hensema.net> <20040106095909.7243b2ce.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: erik@hensema.net, torvalds@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040106095909.7243b2ce.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Jan 06, 2004 at 09:59:09AM -0800, David S. Miller escreveu:
> On Tue, 6 Jan 2004 16:59:34 +0100
> Erik Hensema <erik@hensema.net> wrote:
> 
> > David: are you sure it was fixed in rc1?
> > 
> > It doesn't seem to be in -rc2 either.
> > 
> > This is after 26 hours uptime:
> > 
> > tcp6_sock           6246   6248   1024    4    1 : tunables   54   27    0
> > : slabdata   1562   1562      0
> 
> Someone mentioned about a bug in the userland program you're
> using that is openning these sockets?  Something about leaving sockets
> not closed.
> 
> (Arnaldo, we aparently still have a TCP ipv6 socket leak...)

I'll take a look at this.
