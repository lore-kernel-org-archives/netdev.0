From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Thu, 17 Jul 2003 03:58:15 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307162358.DAA12485@dub.inr.ac.ru>
References: <1058398742.5778.26.camel@hades>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, davem@redhat.com, jmorris@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mika.liljeberg@welho.com (Mika Liljeberg)
In-Reply-To: <1058398742.5778.26.camel@hades> from "Mika Liljeberg" at Jul 17, 2003 02:39:02 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> So what's the background for having the hack to specify a tunnel EP with
> a gateway route?

Technically, it allows to avoid creating hundreds of devices to maintain lots
of tunnels.

Actually, it exists due to historical reasons. ipip and ipip6
tunnels used the trick from the very beginning.

But f.e. ipgre device was new, so it uses more correct approach:
actual mapping cross address families can be made via neighbour tables.
But this requires to know an IPv6 address of the nexthop.
Clean, but inconvenient. :-)

Alexey
