From: Petr Baudis <pasky@pasky.ji.cz>
Subject: Re: Linux problems with hundreds of interfaces/routes
Date: Fri, 27 Sep 2002 17:14:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927151413.GA6548@pasky.ji.cz>
References: <20020927114309.GR2655@pasky.ji.cz> <200209271449.SAA21026@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Baudis <pasky@xs26.net>, pekkas@netcore.fi, netdev@oss.sgi.com,
   xs26-dev@xs26.net
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200209271449.SAA21026@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear diary, on Fri, Sep 27, 2002 at 04:49:00PM CEST, I got a letter,
where kuznet@ms2.inr.ac.ru told me, that...
> Hello!

Hello,

> > 2002/09/27 11:11:03 ZEBRA: netlink-listen error: No buffer space available, type=RTM_NEWROUTE(24), seq=426, pid=0
> 
> This means that you exceeded limit on size of neighbour table,
> which is quite predictable when you have lots of interfaces.
> Tune neighbour table size, it is net/ipv6/neigh/default/gc_thresh3 mostly.

Thanks a lot, that fixed the issue! I personally did some research about how
to raise that, but didn't found anything.. I hope that google will get this
post and rank it high ;-).

-- 
 
				Petr "Pasky" Baudis
 
* ELinks maintainer                * IPv6 guy (XS26 co-coordinator)
* IRCnet operator                  * FreeCiv AI occassional hacker
.
<Beeth> Girls are like internet domain names, the ones I like are already taken.
<honx> Well, you can still get one from a strange country :-P
.
Public PGP key && geekcode && homepage: http://pasky.ji.cz/~pasky/
