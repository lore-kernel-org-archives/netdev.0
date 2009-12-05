From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: RFC: how to control device specific features.  sysfs or mod param?
Date: Sat, 05 Dec 2009 01:55:55 -0800
Message-ID: <1260006955.3565.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56080 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177AbZLEJzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 04:55:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a general question to folks to get some kind of consensus on
controlling device-specific modes.  Currently in ixgbe, I can have two
different modes of our Flow Director mechanism.  One is the current one
in use today, the other is part of a patchset for programming n-tuple
filters that will be submitted soon.

My question is I want to toggle the underlying hardware mode to use one
or the other filter mechanism.  I can either do this using a module
parameter, which I'd like to avoid, or I can do this in a sysfs
parameter.  What do people think is the best approach?  Is there another
option I'm not considering here?

Thanks,
-PJ Waskiewicz

