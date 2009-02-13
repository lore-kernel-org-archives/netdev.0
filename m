From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] bnx2: Update 5706/5708 firmware.
Date: Thu, 12 Feb 2009 16:55:21 -0800 (PST)
Message-ID: <20090212.165521.203785177.davem@davemloft.net>
References: <1234396338-14859-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbZBMAz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:55:27 -0500
In-Reply-To: <1234396338-14859-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 11 Feb 2009 15:52:15 -0800

> New firmware fixes a data corruption issue when receiving and
> placing jumbo frames into host buffers.  In some cases, the
> buffer descriptor is not updated correctly and this will lead
> to the driver linking the wrong number of pages into the SKB.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I was hesistent to add this and the other firmware update to net-2.6,
but memory corruption is a very serious issue so applied.

