From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH 0/4] XSA-39 CVE-2013-021[67]: Linux netback DoS via
 malicious guest ring.
Date: Wed, 6 Feb 2013 17:18:01 +0000
Message-ID: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:4844 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024Ab3BFRSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 12:18:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Xen netback implementation contains a couple of flaws which can
allow a guest to cause a DoS in the backend domain, potentially
affecting other domains in the system.

CVE-2013-0216 is a failure to sanity check the ring producer/consumer
pointers which can allow a guest to cause netback to loop for an
extended period preventing other work from occurring.

CVE-2013-0217 is a memory leak on an error path which is guest
triggerable.

The following series contains the fixes for these issues, as previously
included in Xen Security Advisory 39:
http://lists.xen.org/archives/html/xen-announce/2013-02/msg00001.html

Ian.
