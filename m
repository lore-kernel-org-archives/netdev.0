From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing
 Protocol, revision 20090428
Date: Wed, 29 Apr 2009 14:35:34 -0700 (PDT)
Message-ID: <20090429.143534.32129577.davem@davemloft.net>
References: <20090429210436.a515465b.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090429115716.3e315812@nehalam>
	<20090430065950.529359e3.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43530
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751667AbZD2Vfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 17:35:40 -0400
In-Reply-To: <20090430065950.529359e3.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Date: Thu, 30 Apr 2009 06:59:50 +0930

> So should I submit patches that rip every protocol out of the kernel
> that could be implemented in user space using AF_PACKET?

Don't be rediculious.

The deciding factor is actually one of performance.

And I can't see how putting this into userspace makes it any less
usable, performance wise.  Whereas for protocols that we do have in
the kernel, performance does matter.

Stephen is right, this protocol could very well be more appropriately
implemented in userspace.
