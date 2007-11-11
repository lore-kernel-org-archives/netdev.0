From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] Consolidate equal handlers in tunnel4.c
Date: Sat, 10 Nov 2007 21:50:52 -0800 (PST)
Message-ID: <20071110.215052.24017883.davem@davemloft.net>
References: <47345E38.4010407@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752118AbXKKFux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:50:53 -0500
In-Reply-To: <47345E38.4010407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 09 Nov 2007 16:18:48 +0300

> Two sets - tunnel[6]4_rcv() and tunnel[6]4_err - do the same
> thing, but scan for different lists of tunnels, so this code
> is easily consolidated.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.ogr>

This doesn't apply because I did not apply your
IPTUNNEL_RCV() change.
