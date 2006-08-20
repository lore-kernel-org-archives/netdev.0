From: Valerie Henson <val_henson@linux.intel.com>
Subject: Proper pci_enable_device() error handling in resume routine
Date: Sat, 19 Aug 2006 22:29:22 -0700
Message-ID: <20060820052922.GH20111@goober>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8124 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750759AbWHTF3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 01:29:46 -0400
Received: from localhost.localdomain ([134.134.16.96])
	by orsfmr101.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k7K5TXSI023498
	for <netdev@vger.kernel.org>; Sun, 20 Aug 2006 05:29:34 GMT
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm trying to properly handle pci_enable_device() errors in the resume
routines of a couple of tulip drivers.  I noticed that several drivers
pay attention to errors from pci_enable_device() in the init routine
but ignore it on resume; other drivers vary wildly.  What's proper
behavior when resuming?  Extant examples:

0. Don't call pci_enable_device() at all (8139too)
1. Ignore the return value (eepro100, many others)
2. Check for failure and bail out, but return success (sungem)

-VAL
