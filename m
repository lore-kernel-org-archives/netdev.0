From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 0/2] HW VLAN filtering control (resend)
Date: Fri, 27 Jul 2007 14:30:19 -0700
Message-ID: <1185571819.28574.24.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12376 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765119AbXG0VaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 17:30:20 -0400
Received: from strongmad.jf.intel.com (strongmad.jf.intel.com [10.23.35.99])
	by nwlxmail01.jf.intel.com (8.12.11.20060308/8.12.9/MailSET/Hub) with ESMTP id l6RLUJNQ011330
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2007 14:30:19 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds the capability to disable hardware VLAN filtering at
runtime via the existing vconfig utility.  It's useful for debugging
purposes.

The first patch modifies the VLAN subsystem to define the flag, and to
support passing the flag on to the base driver.

The second patch modifies e1000 to support the flag.  Since it's only
one function, other drivers can be easily modified to support this
functionality.

vconfig is used without modification to enable or disable filtering:
	# vconfig [vlan-interface] 2 1
will disable filtering, and
	# vconfig [vlan-interface] 2 0
will enable filtering.

(Now with non-mangled goodness.)

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
