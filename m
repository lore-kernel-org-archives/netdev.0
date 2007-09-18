From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6.24][patch 2/2] Dynamically allocate the loopback
 device
Date: Mon, 17 Sep 2007 18:53:49 -0700 (PDT)
Message-ID: <20070917.185349.98863851.davem@davemloft.net>
References: <20070917101314.5d1673da@freepuppy.rosehill.hemminger.net>
	<46EECCD5.5090601@fr.ibm.com>
	<224b7d320709171212o66734847kbd17efa817b482fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	containers@lists.osdl.org, benjamin.thery@bull.net
To: pjwaskiewicz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753878AbXIRBxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 21:53:51 -0400
In-Reply-To: <224b7d320709171212o66734847kbd17efa817b482fc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Peter Waskiewicz" <pjwaskiewicz@gmail.com>
Date: Mon, 17 Sep 2007 12:12:24 -0700

> This would be a good opportunity to remove the single-allocated queue struct
> in netdevice (at the bottom) that we had to put in to accomodate the static
> loopback.  Now we can set it back to a zero element list, and have
> alloc_netdev_mq() just allocate the number of queues requested, not
> num_queues - 1.
> 
> I'll put a patch together based on this patchset.

Thanks Peter.

I'll also let this sit so that Eric can provide any feedback
he wants and also figure out how he will use this for the
namespace stuff.
