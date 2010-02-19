From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Fri, 19 Feb 2010 03:20:56 -0800
Message-ID: <1266578456.25502.23.camel@localhost.localdomain>
References: <4B593B74.2020601@jp.fujitsu.com>
	 <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com>
	 <4B5EC215.5090509@jp.fujitsu.com>
	 <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>
	 <4B7E48F8.7010208@jp.fujitsu.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"chavey@google.com" <chavey@google.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62575 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049Ab0BSLU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 06:20:57 -0500
In-Reply-To: <4B7E48F8.7010208@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-19 at 01:16 -0700, Taku Izumi wrote:
> Hi Jesse,
> 
> > I have a counter proposal to make, here is a (incomplete) patch that we
> > use all the time to debug tx hangs.  This example is for e1000e.  We are
> > trying to avoid changes with other users' copyright to some of the files
> > in our drivers so that we can ship them under multiple license.  We would
> > much prefer something like this to be used, can you review?
> 
>   I haven't understood yet about the reason we have to avoid changing some
>   files. Are there any files (header files?) we can't modify?
> 
> Best regards,
> Taku Izumi
> 

To answer your question, no there are no files you can't submit patches
to.  We do have some common files which are used/shared amongst all of
our drivers which are used for initializing and/or bring up the
hardware, so when a patch is submitted to our drivers which changes our
"shared code" our first question is "Is this change necessary for all of
our drivers?" and if the answer is no, then we take a look at what
changes can be made in the code which is not shared among our other
drivers.

-- 
Cheers,
Jeff

