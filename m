From: David Miller <davem@davemloft.net>
Subject: Re: [v2,PCI] move ICHx GbE NVM write-protection from e1000e to PCI
 quirk
Date: Mon, 17 Nov 2008 11:49:52 -0800 (PST)
Message-ID: <20081117.114952.81357471.davem@davemloft.net>
References: <20081116.191252.80669091.davem@davemloft.net>
	<4921C8B0.9060301@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46621
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752446AbYKQTtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 14:49:52 -0500
In-Reply-To: <4921C8B0.9060301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>
Date: Mon, 17 Nov 2008 14:40:32 -0500

> David Miller wrote:
> > I'm less than thrilled with this patch so I'm not going to apply it.
> > I mean, what are we going to do, for every single device that has a
> > NVRAM we're going to add some PCI quirk and some new global foo_*
> > kernel command line option to turn it off?
> > That doesn't make any sense at all, sorry.
> 
> Could we protect it in a PCI quirk, and optionally unprotect it in the driver?

I think it's an overreaction, frankly.

Doing it purely in the driver should be fine.

Again are we going to add a NVRAM protect quirk for every PCI
device on the planet that has a NVRAM?

It's not appropriate at all.
