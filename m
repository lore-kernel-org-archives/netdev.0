From: Sonny Rao <sonnyrao@us.ibm.com>
Subject: Re: [PATCHv2] Add missing memory barriers to clean_rx_irq
 functions in Intel Drivers
Date: Tue, 27 Jul 2010 17:51:41 -0500
Message-ID: <20100727225141.GP17248@us.ibm.com>
References: <20100727223452.GM17248@us.ibm.com>
 <20100727224434.GN17248@us.ibm.com>
 <AANLkTikMNFSyPxRCXc=cPWHkOfsx9iH0mEu-TH7bHL_h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52868 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab0G0WuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 18:50:25 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6RMajeZ026795
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 18:36:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6RMoL9a1937482
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 18:50:21 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6RMoKfN022157
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 18:50:21 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikMNFSyPxRCXc=cPWHkOfsx9iH0mEu-TH7bHL_h@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 03:45:42PM -0700, Jeff Kirsher wrote:
> > --
> 
> You also seem to be missing igb.

You're right, at first I looked at igb and didn't see the analgous bit
of code but I apparently didn't look hard enough.. stand by for
version 3 

-- 
Sonny Rao, LTC OzLabs, BML team
