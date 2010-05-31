From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] fixes to arp_notify for virtual machine migration
 use case
Date: Mon, 31 May 2010 00:32:47 -0700 (PDT)
Message-ID: <20100531.003247.245412006.davem@davemloft.net>
References: <1274779201.24218.7164.camel@zakaz.uk.xensource.com>
	<20100525.230822.71096271.davem@davemloft.net>
	<1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	Jeremy.Fitzhardinge@citrix.com, stable@kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54333
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755744Ab0EaHch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 03:32:37 -0400
In-Reply-To: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 26 May 2010 11:08:12 +0100

> Ian Campbell (3):
>       arp_notify: document that a gratuitous ARP request is sent when this option is enabled
>       arp_notify: allow drivers to explicitly request a notification event.
>       xen: netfront: explicitly generate arp_notify event after migration.

Applied to net-next-2.6, there was a new bonding notifier added meanwhile
and I changed the number of your new notifier to fix the conflict.
