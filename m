From: Tim Mattox <tmattox@gmail.com>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Fri, 30 Jul 2004 15:29:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <ea86ce220407301229522be64f@mail.gmail.com>
References: <20040730060348.GA22854@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040730060348.GA22854@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I looked into fastroute about a year ago as well.  It's been used in
some clusters
AFAIK, but I'm not sure if it's still being actively used.  I was
considering trying to
use it myself in some cluster FNN research work I'm doing.  But that's probably
still 6 months away if I get to it.  Since I'd be having to patch
other things anyway,
I have no qualms with it going away from mainline...  Especially with GigE so
cheap today, and legacy PCI bandwidths so low, it's not particularly economical
today to route through nodes in an HPC cluster that uses TCP/IP interconnect.

I don't know if the webserver/load balancing community would mind it going
away though.

On Fri, 30 Jul 2004 02:03:48 -0400, Jeff Garzik <jgarzik@pobox.com> wrote:
[snip]
> This actually does something, dependent upon options from the packet
> socket, so I left it alone.  The rest was dead code.
> 
> If nobody objects I can push to David, but right now this is more
> an RFC than a merge request for David.
[snip]

-- 
Tim Mattox - tmattox@gmail.com - http://homepage.mac.com/tmattox/
