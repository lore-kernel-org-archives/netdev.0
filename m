From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: IMQ / new Dummy device post.
Date: Mon, 19 Apr 2004 10:14:48 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404191013590.18235@tux.rsn.bth.se>
References: <407E5905.9070108@dsl.pipex.com>  <1082031313.1039.13.camel@jzny.localdomain>
  <407EE3E5.8060200@dsl.pipex.com>  <1082087553.1035.287.camel@jzny.localdomain>
  <4080356F.4020609@dsl.pipex.com>  <1082145341.1026.125.camel@jzny.localdomain>
  <40810957.6030209@dsl.pipex.com>  <1082203795.1043.18.camel@jzny.localdomain>
  <4081A824.5020107@dsl.pipex.com>  <1082298480.1041.94.camel@jzny.localdomain>
  <4082AE45.7030101@dsl.pipex.com>  <1082321582.1039.319.camel@jzny.localdomain>
 <1082323432.13261.397.camel@tux.rsn.bth.se> <4082FA09.2040404@dsl.pipex.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <4082FA09.2040404@dsl.pipex.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 18 Apr 2004, Andy Furniss wrote:

> > with connmark you mark the connection, and then you can "restore" that
> > mark to packets in either direction in the mangle table of iptables.
> >
> > connmark isn't incompatible with connbytes. It's just that both patches
> > modify the same part of the code, a struct, and the patch program can't
> > handle that. You'll have to fix some rejects by hand, that's it.
> >
>
> Thanks for that - though I hope not to have to use it now, just to
> confirm - does it work in all of the 5 mangle tables or more
> specifically could I mark every connection from local processes in
> output and restore the marks in prerouting?

It works in all of the 5 mangle chains iirc.

/Martin
