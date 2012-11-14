From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: IPv6 bonding support?
Date: Wed, 14 Nov 2012 11:34:19 -0800
Message-ID: <23691.1352921659@death.nxdomain>
References: <5791379.6.1352881597330.JavaMail.root@zimbra>
Cc: netdev@vger.kernel.org
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:39859 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212Ab2KNTed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 14:34:33 -0500
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 14 Nov 2012 14:34:29 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id F1812C9003E
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 14:34:25 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAEJYPNS190118
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 14:34:25 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAEJYOIq013778
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 12:34:24 -0700
In-reply-to: <5791379.6.1352881597330.JavaMail.root@zimbra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roy Sigurd Karlsbakk <roy@karlsbakk.net> wrote:

>I've setup bonding on a few machines here. They're all blades in a Dell
>blade chassis, so they're both connected to the four internal switches
>(2 gigE, 2 10GigE). Using 10GigE only, I've setup bonding in
>active-backup mode with the ARP driver. While this works well, we're
>planning ahead for running IPv6 only.
>
>Does anyone kow if something's in the works to allow redundant links in
>an IPv6-only setup?

	I am not aware of any implementation or plans to implement an
IPv6 equivalent to the ARP monitor (arp_interval, et al) in bonding.

	If the blade switches support a trunk failover system (wherein
the switch will drop carrier on internal facing ports when carrier is
lost on an external port), it is possible to implement approximately
equivalent functionality using trunk failover and the bonding mii
monitor (miimon).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
