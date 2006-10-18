From: "Bar, Eitan" <eitanb@ti.com>
Subject: RE: 80211 questions
Date: Wed, 18 Oct 2006 15:45:09 +0200
Message-ID: <19EFC4D481EBF849B14F91557CA737B54A6839@dile02.ent.ti.com>
References: <1161178178.5575.24.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:22697 "EHLO bear.ext.ti.com")
	by vger.kernel.org with ESMTP id S1161016AbWJRNqM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 09:46:12 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1161178178.5575.24.camel@ux156>
To: "Johannes Berg" <johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Johannes Berg [mailto:johannes@sipsolutions.net]
> Sent: Wednesday, October 18, 2006 3:30 PM
> To: Bar, Eitan
> Cc: netdev@vger.kernel.org
> Subject: Re: 80211 questions
> 
> Hi,
> 
> > I'm working on adding WE (wireless extensions) support to a WLAN
> > driver, and have recently bumped into references of nl80211,
cfg80211
> > and d80211.
> >
> > My questions:
> > - Can someone please shortly describe each term?
> 
> d80211: wireless stack slated to replace the current ieee80211
subsystem
> in the kernel, includes very advanced functionality and can drives
> softmac chipsets like bcm43xx.
> 
> cfg80211: my proposal for the in-kernel wireless configuration
interface
> replacing WE
> 
> nl80211: tightly tied to cfg80211, this exports the cfg80211 interface
> over netlink to userspace
> 
> There's also a compat interface so drivers can use cfg80211 but
> userspace can continue to use WE.
> 

 [Eitan Bar] Thanks :)


> > - Other than reading the source code and searching in news-groups,
is
> > there any serious source of information regarding any of the above?
> 
> not really, sorry. What specifically do you need? Also, what driver
are
> you adding support for? Could it make sense to make said driver use
> d80211, or is it for a fullmac chipset?
> 

[Eitan Bar] I was actually looking for any kind of design document, or
anything related to the concept behind it.
I'm adding WE support for a Texas Instruments driver for future
chipsets. The driver is, at the moment, entirely proprietary (including
user-mode API).

> > p.s: while I'm at it -> any good documentation on WE itself other
than
> > wireless.20.h ?
> 
> None as far as I know. Jean recommends reading the userspace tools
> source code (which from my POV shows just /how/ broken WE is).

[Eitan Bar] I see. Can you please point out if there's any driver
currently supporting cfg80211 or nl80211 for reference? (which one are
you using for testing?)

> 
> johannes
