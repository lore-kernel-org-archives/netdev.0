From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy_device: Interrupt number 0 is valid
Date: Wed, 08 Oct 2008 09:43:35 -0700 (PDT)
Message-ID: <20081008.094335.216774973.davem@davemloft.net>
References: <48ECA4A0.7080508@teltonika.lt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paulius.zaleckas@teltonika.lt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753976AbYJHQn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 12:43:59 -0400
In-Reply-To: <48ECA4A0.7080508@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Date: Wed, 08 Oct 2008 15:16:32 +0300

> If interrupt number 0(valid interrupt number) will be passed as
> phy interrupt it should be used. In current situation even phy
> polling will not work since PHY_POLL = -1
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

In the Linux kernel, interrupt number 0 is defined as not valid.
