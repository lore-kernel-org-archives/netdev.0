From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] Arp announce (for Xen)
Date: Fri, 2 Mar 2007 11:59:13 -0800
Message-ID: <20070302115913.69204ac7@freekitty>
References: <20070301232443.195603797@goop.org>
	<20070301232529.648076372@goop.org>
	<20070301164214.4a40bc59@freekitty>
	<45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
	<Pine.LNX.4.64.0703021006470.27021@netcore.fi>
	<45E86D21.6080208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pekka Savola <pekkas@netcore.fi>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39272 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965136AbXCBT7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 14:59:19 -0500
In-Reply-To: <45E86D21.6080208@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Mar 2007 10:29:53 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Pekka Savola wrote:
> > On Thu, 1 Mar 2007, Stephen Hemminger wrote:
> >> What about implementing the unused arp_announce flag on the inetdevice?
> >> Something like the following.  Totally untested...
> >>
> >> Looks like it either was there (and got removed) or was planned but
> >> never implemented.
> IN_DEV_ARP_ANNOUNCE is in 2.6.18, at least..used in arp_solicit in arp.c
> 
> I really hope this didn't get removed because I find it very useful!
> 
> But, you could certainly add another sysctl...
> 
> Thanks,
> Ben
> 

yeah, something new like arp_notify? or arp_gratiutous

There are other drivers that do their own arp, they need to be fixed.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
