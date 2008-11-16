From: David Miller <davem@davemloft.net>
Subject: Re: macb phy address bug?
Date: Sun, 16 Nov 2008 01:50:50 -0800 (PST)
Message-ID: <20081116.015050.238612963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: giulio.benetti@micronovasrl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751588AbYKPJuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 04:50:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've applied this patch to net-2.6, thanks.

As mentioned there is some rare chance that the new
zero test could cause problems, in which case we'll
need to undo that part.
