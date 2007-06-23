From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 13:57:37 -0700 (PDT)
Message-ID: <20070623.135737.22037347.davem@davemloft.net>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net>
	<m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	jeff@garzik.org, yoshfuji@linux-ipv6.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52326
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751411AbXFWU5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 16:57:19 -0400
In-Reply-To: <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 23 Jun 2007 11:19:34 -0600

> Further and fundamentally all a global achieves is removing the need
> for the noise patches where you pass the pointer into the various
> functions.  For long term maintenance it doesn't help anything.

I don't accept that we have to add another function argument
to a bunch of core routines just to support this crap,
especially since you give no way to turn it off and get
that function argument slot back.

To be honest I think this form of virtualization is a complete
waste of time, even the openvz approach.

We're protecting the kernel from itself, and that's an endless
uphill battle that you will never win.  Let's do this kind of
stuff properly with a real minimal hypervisor, hopefully with
appropriate hardware level support and good virtualized device
interfaces, instead of this namespace stuff.

At least the hypervisor approach you have some chance to fully
harden in some verifyable and truly protected way, with
namespaces it's just a pipe dream and everyone who works on
these namespace approaches knows that very well.

The only positive thing that came out of this work is the
great auditing that the openvz folks have done and the bugs
they have found, but it basically ends right there.
