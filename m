From: "Kevin Lloyd" <klloyd@sierrawireless.com>
Subject: RE: Network device driver with PPP
Date: Thu, 28 Feb 2008 08:19:45 -0800
Message-ID: <3415E2A2AB26944B9159CDB22001004D024DA7DC@nestea.sierrawireless.local>
References: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local> <1204164955.26292.5.camel@localhost.localdomain> <47C67E67.70604@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "James Chapman" <jchapman@katalix.com>,
	"Dan Williams" <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sierrawireless.com ([208.81.121.7]:30901 "EHLO
	mx1.sierrawireless.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571AbYB1QR5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 11:17:57 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47C67E67.70604@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That seems quite icky to do all in kernel space and a pile of code
> running in the kernel.  What's so wrong with userspace?  Don't you
need
> to push values to the driver like username/password and get IP config
> out of it (which would involve userspace anyway)?  It just seems like
> there's a different solution to your actual problem here than stuff
all
> off pppd into kernel space.

Actually we provide a method for the driver to obtain the
username/password information needed for the CHAP authentication so in
theory the driver has the information needed to create the connection.
I'm not sure how it would go about setting the DNS and IP addresses, but
that's a separate issue further down the road.

I understand that typical implementation is to deal with ppp
negotiations in the userspace however are there no devices that have
attempted this in the kernel space / no kernel space modules to aid with
this? Just trying to do a full investigation of all available options,
even if they aren't the best ones.
If not, is there a method for the network driver to launch pppd with a
given set of parameters (not using udev) since the driver would be
determining username/password runtime.

Thanks your help,
-Kevin
