From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][UNIX] Make unix_tot_inflight counter non-atomic
Date: Sat, 10 Nov 2007 22:06:10 -0800 (PST)
Message-ID: <20071110.220610.159518173.davem@davemloft.net>
References: <4731C324.3080301@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752190AbXKKGGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:06:11 -0500
In-Reply-To: <4731C324.3080301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 07 Nov 2007 16:52:36 +0300

> This counter is _always_ modified under the unix_gc_lock spinlock, 
> so its atomicity can be provided w/o additional efforts.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
