From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Wed, 29 Oct 2008 16:45:05 -0700 (PDT)
Message-ID: <20081029.164505.121434157.davem@davemloft.net>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
	<20081029153928.3d47e26f@extreme>
	<000b01c93a1c$090222c0$6c01a8c0@RHEELAPTOP>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rhee@eos.ncsu.edu, netdev@vger.kernel.org
To: rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751047AbYJ2Xpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 19:45:30 -0400
In-Reply-To: <000b01c93a1c$090222c0$6c01a8c0@RHEELAPTOP>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Injong Rhee" <rhee@ncsu.edu>
Date: Wed, 29 Oct 2008 19:14:03 -0400

> >
> > This looks like a good optimization, it obviously needs more testing
> > because Linux always seems to find new broken hardware.  The areas
> > that need to be tested should include:
> >  * MacOs has a broken version of delayed ack that might cause
> >    HyStart to radically underestimate.
> 
> We tested with FreeBSD. I presume that it covers MacOS. We will look into that.

Not even close, Apple made an enormous number of local modifications
to the BSD tcp stack in their copy of the code base.

That's where the dupack behavior comes from, FreeBSD never did
that stuff.
