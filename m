From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Thu, 05 Jun 2008 07:43:24 -0700 (PDT)
Message-ID: <20080605.074324.38999631.davem@davemloft.net>
References: <20080527141339.12851.98781.stgit@localhost.localdomain>
	<20080604.114456.32717312.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC32905348FD4@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754836AbYFEOnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 10:43:25 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32905348FD4@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 4 Jun 2008 23:23:00 -0700

> I'm not sure I follow this.  DCB is a scheduling policy, but that
> scheduling policy is in the hardware.  The configuration interface,
> which is what this is, happens out of band of any scheduling policies in
> the kernel.  It's very analogous to the wireless configuration layer for
> mac80211 that uses generic netlink.

And I'm saying we should have a equivalent software scheduler in
the kernel that can implement this if the hardware offloaded version
isn't present.

It overlaps existing functionality to a certain extent, and there is
no real reason for that overlap to exist.  The question is which
(the existing facilities or the new one) subsumes which.
