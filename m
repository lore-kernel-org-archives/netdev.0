From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Tue, 04 Nov 2008 23:33:13 -0800 (PST)
Message-ID: <20081104.233313.109709104.davem@davemloft.net>
References: <1225809909.10206.90.camel@localhost.localdomain>
	<20081104.134236.115613394.davem@davemloft.net>
	<1225868744.31605.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751563AbYKEHdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 02:33:37 -0500
In-Reply-To: <1225868744.31605.12.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Wed, 05 Nov 2008 08:05:44 +0100

> A strange observation is the IRQ allocations seen via /proc/interrupts:
> (e.g. eth2 has assigned no less than 12 IRQs !?!)

One for each TX and RX queue and then one for "other events".

If you disable MSI on the system (I forget the kernel command
line option offhand) does that make the problem go away?
