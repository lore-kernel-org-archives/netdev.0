From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 4 Oct 2011 15:27:58 -0700
Message-ID: <20111004152758.3c5efc22@nehalam.linuxnetplumber.net>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	<20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
	<m27h4klmls.fsf@firstfloor.org>
	<20111004140754.0e677941@nehalam.linuxnetplumber.net>
	<1317766638.21658.11.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, Kevin Wilson <wkevils@gmail.com>,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33747 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933180Ab1JDW2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 18:28:04 -0400
In-Reply-To: <1317766638.21658.11.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Oct 2011 15:17:18 -0700
Sridhar Samudrala <sri@us.ibm.com> wrote:

> On Tue, 2011-10-04 at 14:07 -0700, Stephen Hemminger wrote:
> > On Tue, 04 Oct 2011 09:58:55 -0700
> > Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > Stephen Hemminger <shemminger@vyatta.com> writes:
> > > 
> > > > This adds a new 'br' command which is the bridging equivalent of
> > > > the ip command. More of a demo of how to use netlink and bridging
> > > > at this point.
> > > 
> > > Please name it "bridge", not "br"
> > > 
> > > -Andi
> > 
> > Ok, but it breaks the existing pattern.
> 
> Is this supposed to replace brctl utility?
> 
> Can we add/delete a bridge and add/delete interfaces to a bridge using
> this command?
> 
> If so, why not make it
>    ip bridge add/del <brname> 
>    ip bridge addif/delif <brname> <ifname>
> 

You can already use 'ip link' to add/delete bridge, and add interface
to bridge by setting master.
