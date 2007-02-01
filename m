From: Joy Latten <latten@austin.ibm.com>
Subject: when having to acquire an SA, ipsec drops the packet
Date: Thu, 01 Feb 2007 16:51:21 -0600
Message-ID: <1170370281.2603.359.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, vyekkirala@TrustedCS.com, jmorris@namei.org,
	herbert@gondor.apana.org.au, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:59186 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933148AbXBAXG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 18:06:29 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l11N7751027368
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 18:07:07 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11N6RGA236156
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 18:06:27 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11N6QJs004496
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 18:06:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPsec returns EAGAIN when it needs to acquire an SA.
There have been a thread or two about this...
Has there been any info or progress in how best to fix this?

James Morris presented some work/ideas,
http://vger.kernel.org/jmorris_ipsec_sa_resolution_netconf2006.pdf

When using labeled xfrms (xfrms that contain a security context), there
is potential for a greater amount of SAs to be created than when using
regular xfrms. An SA may be created every time a different security
context is encountered in a particular traffic stream. This could be
many if each networking app has its own security context, making current
behavior problematic.

Bugreport 225328 has been opened in the Redhat Bugzilla to address
when having to acquire an SA, ipsec drops the packet.

Regards,
Joy

