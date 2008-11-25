From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
 driver
Date: Tue, 25 Nov 2008 00:47:36 -0800 (PST)
Message-ID: <20081125.004736.149304104.davem@davemloft.net>
References: <cover.1227562829.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36149
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751928AbYKYIrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 03:47:37 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Mon, 24 Nov 2008 13:50:23 -0800

> This patchset (or the linux-wimax GIT tree at git.kernel.org) merges
> the WiMAX subsystem and driver for the Intel 2400m Wireless WiMAX
> connection to the tree. We'd like to get it in for the 2.6.29 merge
> window. 

You've made this difficult by creating the dependency on
the USB changes.

So I can't, for example, merge this into the networking tree.
Is there some way you can make the driver work without the
USB changes even with some hack?

Second, put the wimax stack stuff under net/wimax just like
we do for net/mac80211 et al.  Then just the drivers go under
drivers/net/wimax
