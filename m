From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 07 Mar 2011 13:40:01 -0800 (PST)
Message-ID: <20110307.134001.245386278.davem@davemloft.net>
References: <CFE9BFE80FFE4D4892AA5D31387E310F02F3ED@mtldag01.mtl.com>
	<20110307213648.GA18682@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@purestorage.com, netdev@vger.kernel.org
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38944
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756330Ab1CGVjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:39:23 -0500
In-Reply-To: <20110307213648.GA18682@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Mon, 7 Mar 2011 23:36:48 +0200

> Specifically, some archs may not support write combining.

They should just create a non-write-combining mapping if they
don't support it.

It could still fail due to resource constraints, but not because
of the reason you're stating.
