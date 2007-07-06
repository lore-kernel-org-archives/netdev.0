From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [Cbe-oss-dev] [PATCH] ps3: gigabit ethernet driver for PS3, take3
Date: Fri, 6 Jul 2007 13:02:41 -0500
Message-ID: <20070706180241.GB4457@austin.ibm.com>
References: <468D2098.50507@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geoff Levand <geoffrey.levand@am.sony.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, Jeff Garzik <jeff@garzik.org>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:58804 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762341AbXGFSCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 14:02:45 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l66I2gd8028869
	for <netdev@vger.kernel.org>; Fri, 6 Jul 2007 14:02:42 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l66I2gcl267072
	for <netdev@vger.kernel.org>; Fri, 6 Jul 2007 12:02:42 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l66I2fTU024203
	for <netdev@vger.kernel.org>; Fri, 6 Jul 2007 12:02:42 -0600
Content-Disposition: inline
In-Reply-To: <468D2098.50507@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 11:47:20AM -0500, jschopp wrote:
> 
> This is the third submission of the network driver for PS3.
> The differences from the previous one are:

I notice that this mostly a cut-n-paste of a very old version
of the spidernet device driver.  Please note that the old
spidernet had absolutely disasterous performance for transmit;
it also had a variety of crazy hangs and lockups under 
high-stress conditions; or NFS operation, or certain back-to-back
tcp usage scenarios. A few dozen bugfixes went in since
the time that the gelic snapshot was taken.

Wouldn't it be better to just add the hypervisor bits-n-pieces 
to spidernet?  That way, you get not only the various fixes, but 
also the benefit of fairly regular testing...


--linas
