From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 10:09:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819100929.0bfefbb4.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
	<20030819145403.GA3407@alpha.home.local>
	<20030819170751.2b92ba2e.skraw@ithnet.com>
	<20030819085717.56046afd.davem@redhat.com>
	<20030819185219.116fd259.skraw@ithnet.com>
	<20030819095302.7213ddd5.davem@redhat.com>
	<20030819191246.027061dd.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@w.ods.org, richard@aspectgroup.co.uk, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephan von Krawczynski <skraw@ithnet.com>
In-Reply-To: <20030819191246.027061dd.skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 19:12:46 +0200
Stephan von Krawczynski <skraw@ithnet.com> wrote:

> On Tue, 19 Aug 2003 09:53:02 -0700
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > In the ARP request we are using the source address in the packet we
> > are building for output.
> > 
> > If ARP doesn't work using that source address, we can only assume IP
> > communication is not possible either.
> > 
> > It is the box not responding to this ARP which is preventing
> > communication not the box creating the ARP request.
> 
> Please read my example from other email. Very simple to prove you wrong here.

Not really, the RFC you keep quoting is broken in several
regards:

1) It is non-functional in environments containing systems
   using the host ownership model for IP addresses which the
   RFC standards fully allow.

2) It does not consider the cases where a host is not completely
   aware of all subnets present on a given link.  This is actually
   quite common.

   Dropping such ARP requests can only be done when the
   the host is aware of all subnets that exist, which is cannot
   be possibly true.
