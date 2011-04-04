From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: convert xen-netfront to hw_features
Date: Mon, 04 Apr 2011 11:08:12 -0700 (PDT)
Message-ID: <20110404.110812.90805188.davem@davemloft.net>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl>
	<20110401.205455.70198735.davem@davemloft.net>
	<1301920159.23887.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	Jeremy.Fitzhardinge@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59167
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755183Ab1DDSIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 14:08:49 -0400
In-Reply-To: <1301920159.23887.96.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Mon, 4 Apr 2011 13:29:19 +0100

>>From 0b56469abe56efae415b4603ef508ce9aec0e4c1 Mon Sep 17 00:00:00 2001
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Mon, 4 Apr 2011 10:58:50 +0100
> Subject: [PATCH] xen: netfront: assume all hw features are available until backend connection setup
> 
> We need to assume that all features will be available when registering the
> netdev otherwise they are ommitted from the initial set of
> dev->wanted_features. When we connect to the backed we reduce the set as
> necessary due to the call to netdev_update_features() in xennet_connect().
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

I've applied this, thanks Ian.
