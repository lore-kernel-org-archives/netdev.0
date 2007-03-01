From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Thu, 1 Mar 2007 17:34:26 -0600
Message-ID: <20070301233426.GH4717@austin.ibm.com>
References: <200702281521.34277.n.eicker@fz-juelich.de> <1e548a3f0703011452u6dde9c53ifde2fa41fe5f4c38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Norbert Eicker <n.eicker@fz-juelich.de>, linuxppc-dev@ozlabs.org,
	Adam Emerich <aemerich@us.ibm.com>, netdev@vger.kernel.org
To: Chris Engel <chrisengel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:50392 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161172AbXCAXe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 18:34:28 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l21NYSZl031745
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 18:34:28 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l21NYRiv552702
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 16:34:28 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l21NYQOH021297
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 16:34:27 -0700
Content-Disposition: inline
In-Reply-To: <1e548a3f0703011452u6dde9c53ifde2fa41fe5f4c38@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 04:52:54PM -0600, Chris Engel wrote:
> I tried to apply this patch to 2.6.21-rc2 and CHECKSUM_HW appears to be
> changed to CHECKSUM_COMPLETE 

The use of CHECKSUM_HW was replaced by CHECKSUM_PARTIAL and CHECKSUM_COMPLETE
on a cae-by-case basis, in the patch series leading up to 2.6.19.  In this case,
I'm not sure which should have been used.

Norbert, can you resubmit a patch that applies to a more recent kernel?
p.s. your emailer replaced tabs by spaces ... 

--linas

