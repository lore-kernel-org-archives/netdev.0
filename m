From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9778] New: unregister_netdevice: waiting for
 [device] to become free
Date: Mon, 21 Jan 2008 04:36:16 -0800 (PST)
Message-ID: <20080121.043616.45484007.davem@davemloft.net>
References: <20080119165802.2846a28e.akpm@linux-foundation.org>
	<20080120.023027.85710827.davem@davemloft.net>
	<20080121121445.GA29459@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, xemul@openvz.org,
	bugme-daemon@bugzilla.kernel.org, nigel@suspend2.net,
	netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55986
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbYAUMgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 07:36:11 -0500
In-Reply-To: <20080121121445.GA29459@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 21 Jan 2008 15:14:45 +0300

> I will think about how to fix the problem nicely or if this patch still
> can be simplified/dropped, but so far it looks valid. Maybe this
> analysis will help someone to fix problem first.

I have currently reverted Pavel's patch.

I have no doubt that his patch was in some aspects
correct, the regressions were worse than the disease
he initially intended to cure.

We can add the race fix back once we get to the
bottom of the reference count issue.
