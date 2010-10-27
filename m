From: David Miller <davem@davemloft.net>
Subject: Re: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Wed, 27 Oct 2010 10:52:28 -0700 (PDT)
Message-ID: <20101027.105228.39197352.davem@davemloft.net>
References: <1288142302.26640.7.camel@voxel>
	<4CC84EAD.7040506@xs4all.nl>
	<1288201734.26640.43.camel@voxel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim876@xs4all.nl, netdev@vger.kernel.org
To: nolan@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753944Ab0J0RwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 13:52:04 -0400
In-Reply-To: <1288201734.26640.43.camel@voxel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nolan Leake <nolan@cumulusnetworks.com>
Date: Wed, 27 Oct 2010 10:48:54 -0700

> I have no idea why ipv6 vetos the upping of a link-down interface, while
> ipv4 doesn't care.
> 
> If this is all intended behavior, then I guess I'll need to make the old
> "tap devices are always link-up" mode the default, and add a way for
> newer software to opt-in into correct link-state reporting.
> 
> David (CC'd), could you comment on this?

If ipv6 cannot send multicast packets for neighbour and router
discovery, which it must do in order to function properly over the
device, the interface is unusable.
