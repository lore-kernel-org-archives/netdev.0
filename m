From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gianfar: Wait for both RX and TX to stop
Date: Tue, 27 Apr 2010 16:44:35 -0700 (PDT)
Message-ID: <20100427.164435.106796832.davem@davemloft.net>
References: <1272408703-20931-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754456Ab0D0Xoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:44:30 -0400
In-Reply-To: <1272408703-20931-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 27 Apr 2010 17:51:43 -0500

> When gracefully stopping the controller, the driver was continuing if
> *either* RX or TX had stopped.  We need to wait for both, or the
> controller could get into an invalid state.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied, thanks.
