From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 04 Oct 2011 15:17:18 -0700
Message-ID: <1317766638.21658.11.camel@w-sridhar.beaverton.ibm.com>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	 <20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
	 <m27h4klmls.fsf@firstfloor.org>
	 <20111004140754.0e677941@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, Kevin Wilson <wkevils@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:43189 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933265Ab1JDWRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 18:17:20 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p94Lu8UZ019544
	for <netdev@vger.kernel.org>; Tue, 4 Oct 2011 15:56:08 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p94MHJsh091404
	for <netdev@vger.kernel.org>; Tue, 4 Oct 2011 16:17:19 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p94MHJhJ013213
	for <netdev@vger.kernel.org>; Tue, 4 Oct 2011 16:17:19 -0600
In-Reply-To: <20111004140754.0e677941@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-04 at 14:07 -0700, Stephen Hemminger wrote:
> On Tue, 04 Oct 2011 09:58:55 -0700
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > Stephen Hemminger <shemminger@vyatta.com> writes:
> > 
> > > This adds a new 'br' command which is the bridging equivalent of
> > > the ip command. More of a demo of how to use netlink and bridging
> > > at this point.
> > 
> > Please name it "bridge", not "br"
> > 
> > -Andi
> 
> Ok, but it breaks the existing pattern.

Is this supposed to replace brctl utility?

Can we add/delete a bridge and add/delete interfaces to a bridge using
this command?

If so, why not make it
   ip bridge add/del <brname> 
   ip bridge addif/delif <brname> <ifname>

Thanks
Sridhar
