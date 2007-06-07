From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/18] spidernet driver bug fixes
Date: Thu, 7 Jun 2007 14:17:07 -0500
Message-ID: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:51287 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933954AbXFGTRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:17:10 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JH9iT031124
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:17:09 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JH8qn198976
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:17:08 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JH8Wq014692
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:17:08 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff, please apply for the 2.6.23 kernel tree.  The pach series
consists of two major bugfixes, and several bits of cleanup.

The major bug fixes are: 

1) a rare but fatal bug involving "RX ram full" messages, 
   which results in a driver deadlock.

2) misconfigured TX interrupts, causing a sever performance
   degardation for small packets.

Minor updates include an expanded ring dump routine, and 
documentation for some portions of the device driver.

--linas

