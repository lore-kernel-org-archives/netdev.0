From: David Miller <davem@davemloft.net>
Subject: Re: [v2,PCI] move ICHx GbE NVM write-protection from e1000e to PCI
 quirk
Date: Sun, 16 Nov 2008 19:12:52 -0800 (PST)
Message-ID: <20081116.191252.80669091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754708AbYKQDMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 22:12:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm less than thrilled with this patch so I'm not going to apply it.

I mean, what are we going to do, for every single device that has a
NVRAM we're going to add some PCI quirk and some new global foo_*
kernel command line option to turn it off?

That doesn't make any sense at all, sorry.
