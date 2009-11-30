From: David Miller <davem@davemloft.net>
Subject: Re: dmfe/tulip device id overlap
Date: Mon, 30 Nov 2009 12:21:33 -0800 (PST)
Message-ID: <20091130.122133.166546743.davem@davemloft.net>
References: <20091130065512.GA2792@jenkins.domain_not_set.invalid>
	<20091129.230703.206229796.davem@davemloft.net>
	<1259585185.3709.181.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brandon@ifup.org, grundler@google.com, tobias@ringis.se,
	kyle@mcmartin.ca, netdev@vger.kernel.org, grundler@parisc-linux.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752496AbZK3UV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:21:28 -0500
In-Reply-To: <1259585185.3709.181.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 30 Nov 2009 12:46:25 +0000

> If the problem is that the drivers are not portable, then this makes
> sense.  However, as I understand it, the problem is that the same device
> ids have been assigned to significantly different controllers/boards.
> In this case it may be better for both of the drivers to claim the
> device ids and to distinguish them at probe time.

It is going to be so easy to tell them apart.

Simply because onboard devices on Sparc are going to have
openfirmware, so there are going to be OF device properties and
whatnot we can probe for if necessary.

And the only difference the chips can have at this level is what kind
of PHY et al. are attached to the MAC.  Fundamentally the devices are
going to be the same.
