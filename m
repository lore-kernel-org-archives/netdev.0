From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 1 Jul 2008 18:48:57 +0400
Message-ID: <20080701144857.GA8774@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <20080701130835.GA29223@2ka.mipt.ru> <486A3426.3000807@trash.net> <20080701141412.GA30644@2ka.mipt.ru> <486A3C3C.3070709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <486A3C3C.3070709@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 01, 2008 at 04:16:28PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> I truely hope it will be since I'm working (slowly, as time permits)
> on the *tables successor that will implement things like this in
> userspace. Every module we add that adds more complicated logic in
> the kernel will make adding an iptables compat layer harder.

It still is very tempting to implement such things as iptables modules.
For example I consider to create tunnel-like device and iptables target
to implement ip-over-dns tunnel, and I need iptables extension since I
only control single machine outside of my ISP which is not firewalled.
Having new way of writing iptables extensions requires to update
existing machines, which is not possible frequently
(like existing enterprise (r) (c) (tm) solutions...)

> I'd CC the netfilter user list, its likely you'll find some voices
> in favour there :)

:)

> >>Yes, but I don't want to add another interface netfilter userspace
> >>has to know about. It should either use nfnetlink and remove the proc
> >>interface, or remove the connector interface and use proc.
> >>Preferrably the former.
> >>    
> >
> >It uses proc to load rules - I do not like it either, but it was the
> >simplest way to do so :)
> 
> We can rethink that part if it will actually get merged.

Sure.

-- 
	Evgeniy Polyakov
