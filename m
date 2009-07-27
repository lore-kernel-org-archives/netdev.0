From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Mon, 27 Jul 2009 15:31:47 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907271530400.5004@ppwaskie-MOBL2.amr.corp.intel.com>
References: <1248266678.17215.15.camel@localhost.localdomain>
 <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>
 <1248338779.17215.23.camel@localhost.localdomain>
 <1248362493.17215.45.camel@localhost.localdomain>
 <1248424910.17215.54.camel@localhost.localdomain>
 <Pine.WNT.4.64.0907241142370.2084@ppwaskie-MOBL2.amr.corp.intel.com>
 <loom.20090727T214746-75@post.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Todd Merritt <tmerritt@email.arizona.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25866 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753209AbZG0WcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 18:32:06 -0400
In-Reply-To: <loom.20090727T214746-75@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jul 2009, Todd Merritt wrote:

> We're getting a panic in the same function with the stable version of the ixgbe
> driver 2.0.38.2-1 on redhat 5 kernel-2.6.18-128.1.10.el5.  Is there a dev
> release of the driver that might have a fix in it ?

Are you also running with preemption enabled?  We're having a very tough 
time reproducing this bug in our lab, so no, we don't have any fix for it 
yet.

-PJ
