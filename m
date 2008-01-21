From: David Miller <davem@davemloft.net>
Subject: Re: post 2.6.24-rc7 regression: unregister_netdevice: waiting for
 eth1 to become free
Date: Sun, 20 Jan 2008 16:32:41 -0800 (PST)
Message-ID: <20080120.163241.80038143.davem@davemloft.net>
References: <200801210109.42153.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
To: m.kozlowski@tuxland.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755027AbYAUAch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 19:32:37 -0500
In-Reply-To: <200801210109.42153.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date: Mon, 21 Jan 2008 01:09:41 +0100

> kernel: unregister_netdevice: waiting for eth1 to become free. Usage count = 1

Known problem:

	http://bugzilla.kernel.org/show_bug.cgi?id=9778
