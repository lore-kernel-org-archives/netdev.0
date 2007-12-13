From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 11:09:28 -0800 (PST)
Message-ID: <20071213.110928.26060224.davem@davemloft.net>
References: <20071213.061938.86541759.davem@davemloft.net>
	<20071213102233.3727e9a0@freepuppy.rosehill>
	<476181C1.3060204@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, joonwpark81@gmail.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	jesse.brandeburg@intel.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760271AbXLMTJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 14:09:28 -0500
In-Reply-To: <476181C1.3060204@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Thu, 13 Dec 2007 14:02:25 -0500

> Or perhaps we should just leave things as is.

We should probably add a "disabling" state bit to the
napi struct flags, this will be set by napi_disable()
before it loops trying to set the sched bit.

net_rx_action() can then check this.
