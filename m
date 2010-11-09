From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] r8169: fix sleeping while holding spinlock.
Date: Tue, 09 Nov 2010 08:27:12 -0800 (PST)
Message-ID: <20101109.082712.71119635.davem@davemloft.net>
References: <20101108232358.GB13720@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel.blueman@gmail.com, rjw@sisk.pl
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752906Ab0KIQ0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 11:26:47 -0500
In-Reply-To: <20101108232358.GB13720@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 9 Nov 2010 00:23:58 +0100

> As device_set_wakeup_enable can now sleep, move the call to outside
> the critical section.
> 
> Signed-off-by: Daniel J Blueman <daniel.blueman@gmail.com>
> Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied.
