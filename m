From: kuznet@ms2.inr.ac.ru
Subject: Re: Linux problems with hundreds of interfaces/routes
Date: Fri, 27 Sep 2002 18:49:00 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271449.SAA21026@sex.inr.ac.ru>
References: <20020927114309.GR2655@pasky.ji.cz>
Mime-Version: 1.0
Cc: pekkas@netcore.fi, netdev@oss.sgi.com, xs26-dev@xs26.net
Return-path: <netdev-bounce@oss.sgi.com>
To: pasky@xs26.net (Petr Baudis)
In-Reply-To: <20020927114309.GR2655@pasky.ji.cz> from "Petr Baudis" at Sep 27, 2 01:43:09 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> 2002/09/27 11:11:03 ZEBRA: netlink-listen error: No buffer space available, type=RTM_NEWROUTE(24), seq=426, pid=0

This means that you exceeded limit on size of neighbour table,
which is quite predictable when you have lots of interfaces.
Tune neighbour table size, it is net/ipv6/neigh/default/gc_thresh3 mostly.

Alexey
