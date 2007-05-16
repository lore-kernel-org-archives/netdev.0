From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/10] spidernet assorted fixes
Date: Wed, 16 May 2007 16:56:05 -0500
Message-ID: <20070516215605.GA4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56129 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039AbXEPV4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 17:56:15 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l4GLqYvG023957
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 17:52:34 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GLuBJa251256
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 15:56:11 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GLuAsE031763
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 15:56:11 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff, 

Please apply & forward upstream the following patch series.

There's a variety of fixes & cleanups in here; the key fix
is a rather hard-to-reproduce bug where the hardware runs out
of ram, resulting in corruption of some sequencer. The only fix
is to reset the card. v-v  Unfortunately, this hard-to-repro
bug is hit during the fedora-core install process. Ugh.

--linas
