From: "Kevin Lloyd" <klloyd@sierrawireless.com>
Subject: RE: Network device driver with PPP
Date: Fri, 29 Feb 2008 17:41:14 -0800
Message-ID: <3415E2A2AB26944B9159CDB22001004D0252D1B7@nestea.sierrawireless.local>
References: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local> <1204164955.26292.5.camel@localhost.localdomain> <47C67E67.70604@katalix.com> <3415E2A2AB26944B9159CDB22001004D024DA7DC@nestea.sierrawireless.local> <47C81E9C.4050903@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Dan Williams" <dcbw@redhat.com>, <netdev@vger.kernel.org>
To: "James Chapman" <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sierrawireless.com ([208.81.121.7]:40722 "EHLO
	mx1.sierrawireless.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886AbYCABj2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 20:39:28 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47C81E9C.4050903@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman wrote:
> > Actually we provide a method for the driver to obtain the
> > username/password information needed for the CHAP authentication so
in
> > theory the driver has the information needed to create the
connection.
> > I'm not sure how it would go about setting the DNS and IP addresses,
but
> > that's a separate issue further down the road.
> 
> Can you explain why you need the driver to be involved in any of this?
I'm trying to evaluate what level of consistency can be maintained for
our drivers across operating systems and whether there is precedence for
such a design. Looking like it's not going to happen...

> Control protocols live in userspace, datapath in the kernel.
Okay. I have a question about the datapath actually: If I have a serial
device and I establish a connection with pppd does it configure the
generic ppp driver to talk to the ttyUSBx port and then route the
control (e.g. NCP and LCP) packets to /dev/ppp for control by pppd and
the data (IP) packets somewhere else? Also is it pppd that directly sets
up the network interface in ifconfig? I'm a little confused/lost here...

> Can't you implement a private interface to your kernel driver so that
> userspace can ask it for the username/password and userspace then
starts
> pppd with those parameters?
Yes I suppose I could do that, how would you recommend approaching this,
ioctl?

Also, is Documentation\networking\ppp_generic.txt up-to-date (says
edited 2002) or is there a better resource explaining ppp architecture
on Linux?

Thanks for your help,
-Kevin
