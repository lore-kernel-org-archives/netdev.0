From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: increase receive packet quantum
Date: Mon, 03 Nov 2008 17:24:28 -0800 (PST)
Message-ID: <20081103.172428.154364341.davem@davemloft.net>
References: <20081103130303.29dd4e21@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56878
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752221AbYKDBYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:24:55 -0500
In-Reply-To: <20081103130303.29dd4e21@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 3 Nov 2008 13:03:03 -0800

> This patch gets about 1.25% back on tbench regression.
> 
> My change to NAPI for multiqueue support changed the time limit on
> network receive processing.  Under sustained loads like tbench, this
> can cause the receiver to reschedule prematurely. 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I think I'm the guilty party that made that change to your
NAPI patches.

I'll apply this to net-next-2.6, thanks Stephen.
