From: Andi Kleen <ak@suse.de>
Subject: Re: Debug kernel network hook chain or why has Check Point Firewall module problems with IPv6
Date: Mon, 22 Apr 2002 15:08:34 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020422150834.A17495@wotan.suse.de>
References: <22830000.1019458033@localhost> <20020422092252.A17861@wotan.suse.de> <20020422130546.17247.qmail@titan.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <20020422130546.17247.qmail@titan.bieringer.de>
List-Id: netdev.vger.kernel.org

On Mon, Apr 22, 2002 at 01:05:46PM +0000, Peter Bieringer wrote:
> 
> Andi Kleen writes:
> 
> > BTW the CheckPoint module seems to leak routes too at least on 2.2, 
> > there are regular reports of that.
> 
> Can you explain what's happen? Perhaps caused by their implementation of
> NAT.

I have no idea what happens exactly, except that there were several reports
to this list of users who ran into problems with an overflowing routing cache.
All they had in common was that they run CheckPoint on 2.2.  There were no
other such reports from non BreakPoint users. I may be fixed in the 2.4
version of their module.

-Andi
