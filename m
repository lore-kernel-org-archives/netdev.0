From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add HAVE_UNREGISTER_NETDEV_QUEUE define for
 out-of-tree modules
Date: Wed, 11 Nov 2009 11:24:57 -0800 (PST)
Message-ID: <20091111.112457.54237892.davem@davemloft.net>
References: <20091110220004.GT21704@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@lhnet.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758490AbZKKTYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 14:24:31 -0500
In-Reply-To: <20091110220004.GT21704@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@lhnet.ca>
Date: Tue, 10 Nov 2009 17:00:04 -0500

> I have an out of tree network driver (GPL'd) that would like to make use of 
> the unregister_netdevice_queue interface for bulk unregister of devices.  
> Add a #define HAVE_UNREGISTER_NETDEV_QUEUE to allow the source to detect 
> that the kernel supports this.

Please get your code upstream :-)

We're already overcluttered with these "HAVE_PANTS", "HAVE_JACKET",
"HAVE_KITCHEN", "HAVE_SINK" ugly defines spewed all over netdevice.h,
and I'm not adding any more of that.
