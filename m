From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] prevent that myri_do_handshake lies about ticks in
 drivers/net/myri_sbus.c
Date: Tue, 13 Nov 2007 03:16:35 -0800 (PST)
Message-ID: <20071113.031635.180568941.davem@davemloft.net>
References: <472F3163.2060302@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 12o3l@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755673AbXKMLQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:16:35 -0500
In-Reply-To: <472F3163.2060302@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <12o3l@tiscali.nl>
Date: Mon, 05 Nov 2007 16:06:11 +0100

> With '<=' tick can be incremented up to 26, The last loop is redundant since 
> even when 'softstate' becomes 'STATE_READY', 'if (tick > 25)' will still cause
> the function to return -1,
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>

Patch applied, thanks.
