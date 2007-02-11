From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: skge dysfunction on Amd X2 machine with 4GB memory
Date: Sun, 11 Feb 2007 16:57:55 +0200
Message-ID: <20070211145755.GW3438@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:53648 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbXBKO55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Feb 2007 09:57:57 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S1648155AbXBKO5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Feb 2007 16:57:55 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the skge driver there seems to be some sort of problem to
work in a system with memory above the 4 GB of PCI address space.

System doesn't crash (not outright anyway) with skge, but that
network interface just doesn't function.

My box has also  forcedeth  network interface, which works just fine.

Running kernel is:  2.6.20-1.2922.fc7

This system board had previously buggy bios that prevented the
functioning with more than around 3GB memory at all.  Now things
do work, and "Rev.E memory hoist" kicks 1280 MB of memory above
the 4 GB mark.

Without the previously dysfunctioning "4GB memory or more" the
same kernel and drivers worked just fine.  Indeed the  skge was
my eth0.

Any ideas ?

  /Matti Aarnio
