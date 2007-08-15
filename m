From: Brandon Philips <bphilips@suse.de>
Subject: [patch 0/4] Update network drivers to use devres
Date: Wed, 15 Aug 2007 11:59:10 -0700
Message-ID: <20070815185910.GA7294@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: teheo@suse.de
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:48342 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926AbXHOS7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 14:59:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches update the network driver core, e100 and e1000 driver to use
devres.  Devres is a simple resource manager for device drivers, see
Documentation/driver-model/devres.txt for more information.

The use of devres will continue to be optional with this patch set and can be
applied to drivers where it makes sense.

This series includes all of the feedback from the final RFC.  Thanks :)
