From: Bill Fink <billfink@mindspring.com>
Subject: Re: ip route show shows the routes in the inverse order?
Date: Wed, 14 Mar 2012 01:30:21 -0400
Message-ID: <20120314013021.4c73af0d.billfink@mindspring.com>
References: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
	<20120312193204.5be5b4b8@nehalam.linuxnetplumber.net>
	<20120313021529.97514922.billfink@mindspring.com>
	<20120312.235234.73408595516828250.davem@davemloft.net>
	<4F5F69C6.7000900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	diego@woitasen.com.ar, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:41650 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754018Ab2CNFbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 01:31:00 -0400
In-Reply-To: <4F5F69C6.7000900@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Mar 2012, Ben Greear wrote:

> On 03/12/2012 11:52 PM, David Miller wrote:
> > From: Bill Fink<billfink@mindspring.com>
> > Date: Tue, 13 Mar 2012 02:15:29 -0400
> >
> >> Some scripts may depend on this plus its much more efficent that way
> >> if trying to find a matching route since you can quit on the first
> >> match instead of having to scan the entire routing table.
> >
> > No script should be doing stuff like this, let the tool do it for you
> > via "ip route get ADDR"
> >
> > There is absolutely no argument for routes to be listed in one order
> > or another, and anything depending upon order is extremely fragile
> > and needs to be fixed up anyways.
> 
> The argument is ease of use by whatever human is reading the
> information..but it could be done in the 'ip' tool.
> 
> Humans are fragile indeed, but it's often easier to fix the
> computer than fix the humans.

Speaking from experience, it's a royal point to look at unsorted
routes.  Perhaps it would be useful to add a sort option to the
"ip route show" command.

It makes more sense to fix a single user tool like "ip" than make
hundreds (or thousands) of admins work around the new behavior.

						-Bill
