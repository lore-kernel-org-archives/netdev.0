From: Tim Mattox <tmattox@gmail.com>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Fri, 30 Jul 2004 16:29:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <ea86ce2204073013292c055a3@mail.gmail.com>
References: <20040730060348.GA22854@havoc.gtf.org> <ea86ce220407301229522be64f@mail.gmail.com> <20040730193515.GA11365@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040730193515.GA11365@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The code that uses (used?) fastroute is not in mainline.  AFAIK there were
two ethernet drivers that you could load that used it, one tulip based
and the other 8390 based.  Here's one of several archives of the
ancient driver code:
http://www.linuxgrill.com/anonymous/fire/alexey/fastroute/
They do not look like they have been maintained, in many years.  It dates
from early 2.2 kernel days.  Apparently in it's day, a Linux box with fastroute
could keep up with a Cisco router, but I've not been able to find the relevant
benchmark numbers via google as of yet, and I've stopped looking.

So, yes, I don't dispute that it's dead code as seen in mainline kernel source,
and should probably be removed now.  If it was still important, we would
have seen fastroute GigE drivers by now, IMHO.

On Fri, 30 Jul 2004 15:35:15 -0400, Jeff Garzik <jgarzik@pobox.com> wrote:
[snip]
> Well my main point is that the code _doesn't do anything_.
> 
> It is dead code, as-is, in the kernel.  It would require patches to
> actually work at all.
> 
> It is impossible that fastrouting is being actively used, without patches.
> 
>         Jeff

Some might consider dropping in a new network driver module a patch,
others wouldn't...  Anyway, as I said before, IMHO I agree its dead code
worthy of removal unless someone comes up with a GigE driver that
actually uses it.
-- 
Tim Mattox - tmattox@gmail.com - http://homepage.mac.com/tmattox/
