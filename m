From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/32] ixgbe section fixes (against netdev)
Date: Thu, 27 Nov 2008 15:34:55 -0800 (PST)
Message-ID: <20081127.153455.198106378.davem@davemloft.net>
References: <E1L3wOM-0006Ti-Jt@ZenIV.linux.org.uk>
	<9929d2390811221143n66f3f09bu3801919a54263589@mail.gmail.com>
	<20081127232335.GF28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752626AbYK0Xez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 18:34:55 -0500
In-Reply-To: <20081127232335.GF28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 27 Nov 2008 23:23:35 +0000

> ixgbe_init_interrupt_scheme() is called from ixgbe_resume().  Build that
> with CONFIG_PM and without CONFIG_HOTPLUG and you've got a problem.
> Several helpers called by it also are misannotated __devinit.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Applied, thanks Al.
