From: Andi Kleen <ak@suse.de>
Subject: Re: Debug kernel network hook chain or why has Check Point Firewall module problems with IPv6
Date: Mon, 22 Apr 2002 14:54:12 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020422145412.A10284@wotan.suse.de>
References: <22830000.1019458033@localhost> <20020422092252.A17861@wotan.suse.de> <20020422085346.12822.qmail@titan.bieringer.de> <20020422120618.A29547@wotan.suse.de> <20020422124737.16885.qmail@titan.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <20020422124737.16885.qmail@titan.bieringer.de>
List-Id: netdev.vger.kernel.org

On Mon, Apr 22, 2002 at 12:47:37PM +0000, Peter Bieringer wrote:
> 
> Andi Kleen writes:
> 
> > On Mon, Apr 22, 2002 at 08:53:45AM +0000, Peter Bieringer wrote:
> > > Is such IPv4 hook not seeing packets leaving a dual-stack application like
> > > openssh? Is there any scheme (the way such packet takes) available for
> > > visualisation.
> > 
> > The v4 hook only sees packets that are sent as v4. The v6 hook only v6.
> > It has nothing to do with the application using v4-mapped-on-v6 sockets 
> > or not.
> 
> Thanks for reply. Is there any tool available which can display which
> application has registered which network hooks?

Only a kernel debugger (gdb vmlinux /proc/kcore) 

-Andi
