From: Erik Hensema <erik@hensema.net>
Subject: Re: 2.6.0: something is leaking memory
Date: Tue, 6 Jan 2004 16:59:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040106155933.GA3373@bender.home.hensema.net>
References: <slrnbvgohn.1pb.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041257290.2162@home.osdl.org> <slrnbvh1hd.jl6.erik@dexter.hensema.net> <Pine.LNX.4.58.0401041826400.2162@home.osdl.org> <20040104204834.40b6ca51.davem@redhat.com>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040104204834.40b6ca51.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 04, 2004 at 08:48:34PM -0800, David S. Miller wrote:
> On Sun, 4 Jan 2004 18:30:21 -0800 (PST)
> Linus Torvalds <torvalds@osdl.org> wrote:
> 
> > You've got 19 _megabytes_ allocated to "tcp6_sock", and they are all 
> > marked as "active". That's almost certainly the leaking bug.
> > 
> > Everything else looks reasonably normal.
>  ...
> > David?
> 
> Fixed by changeset 1.1496.16.1 which is in 2.6.1-rc1

The leak seems to be in 2.6.1-rc1 too and I can't find any IPv6 related
fixes wrt memory in the long format changelog of 2.6.1-rc1.

David: are you sure it was fixed in rc1?

It doesn't seem to be in -rc2 either.

This is after 26 hours uptime:

tcp6_sock           6246   6248   1024    4    1 : tunables   54   27    0
: slabdata   1562   1562      0


-- 
Erik Hensema (erik@hensema.net)
