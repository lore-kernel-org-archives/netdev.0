From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about ixgbevf/ixgbevf_main.c
Date: Tue, 7 Jan 2014 15:46:17 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1401071542370.2094@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: donald.c.skidmore@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:55438 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750817AbaAGOqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 09:46:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was wondering why ixgbevf_suspend doesn't call pci_set_power_state?  It
is called in the corresponding resume function, and most other PCI drivers
with a suspend functyion also call it in suspend.

thanks,
julia
