From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH v4 7/7] AMSO1100 Makefiles and Kconfig changes.
Date: Mon, 28 Aug 2006 16:07:15 -0700
Message-ID: <adazmdoo3x8.fsf@cisco.com>
References: <20060803210723.16572.34829.stgit@dell3.ogc.int>
	<20060803210738.16572.74032.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:9548 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S1751210AbWH1XHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 19:07:18 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20060803210738.16572.74032.stgit@dell3.ogc.int> (Steve Wise's message of "Thu, 03 Aug 2006 16:07:38 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm finally getting around to merging this up, and:

 > --- /dev/null
 > +++ b/drivers/infiniband/hw/amso1100/README
 > @@ -0,0 +1,11 @@
 > +This is the OpenFabrics provider driver for the 
 > +AMSO1100 1Gb RNIC adapter. 
 > +
 > +This adapter is available in limited quantities 
 > +for development purposes from Open Grid Computing.
 > +
 > +This driver requires the IWCM and CMA mods necessary
 > +to support iWARP.
 > +
 > +Contact tom@opengridcomputing.com for more information.
 > +

I don't think this belongs in the drivers directory.  In fact, is it
worth having this in the kernel at all?

How about if I just add a MAINTAINERS entry for amso1100 pointing at
tom@opengridcomputing.com ?

 - R.
