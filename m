From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/34]bnx2x: Potential race after iSCSI boot
Date: Sat, 17 Jan 2009 23:22:54 -0800 (PST)
Message-ID: <20090117.232254.216088277.davem@davemloft.net>
References: <1231951436.11301.145.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33450
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758268AbZARHWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:22:53 -0500
In-Reply-To: <1231951436.11301.145.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:43:56 +0200

> The lock was release too soon. Make sure the HW is marked as locked until the
> boot driver was unloaded from FW perspective
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
