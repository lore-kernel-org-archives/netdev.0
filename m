From: "Peter Bieringer" <pb@bieringer.de>
Subject: Re: Debug kernel network hook chain or why has Check Point Firewall module problems with IPv6
Date: Mon, 22 Apr 2002 08:53:45 GMT
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020422085346.12822.qmail@titan.bieringer.de>
References: <22830000.1019458033@localhost>
            <20020422092252.A17861@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Bieringer <pb@bieringer.de>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
In-Reply-To: <20020422092252.A17861@wotan.suse.de>
To: Andi Kleen <ak@suse.de>
List-Id: netdev.vger.kernel.org


Hi Andi,

thanks for fast answering, need only a short explanation now:

Andi Kleen writes:

> On Mon, Apr 22, 2002 at 08:47:13AM +0200, Peter Bieringer wrote:
> > Looks like CP never sees (or recognizes) packets leaving the
> > firewalled host from a dual-stack application.
> 
> Linux has no "generic" firewall hooks, only protocol specific ones.  
> Checkpoint is probably using the v4 specific ones only.
> Other protocols can be received (by registering a protocol to ETH_P_ALL via
> SOCK_PACKET or in the kernel), but not stolen from protocol handlers. 

Is such IPv4 hook not seeing packets leaving a dual-stack application like
openssh? Is there any scheme (the way such packet takes) available for
visualisation.

TIA,
 Peter
