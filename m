From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V2] CAN: Add Flexcan CAN controller driver
Date: Tue, 28 Jul 2009 16:12:10 +0200
Message-ID: <4A6F073A.1050909@hartkopp.net>
References: <20090728120624.GS2714@pengutronix.de>	<4A6EFB64.8070804@hartkopp.net>	<20090728133719.GU2714@pengutronix.de> <4A6F0238.6050605@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:42742 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbZG1OMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 10:12:12 -0400
In-Reply-To: <4A6F0238.6050605@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
> Sascha Hauer wrote:

>>>> +
>>>> +	if (frame->can_id & CAN_RTR_FLAG)
>>>> +		dlc |= MB_CNT_RTR;
>>>> +
>>>> +	writel(dlc, &regs->cantxfg[TX_BUF_ID].can_dlc);
>>>> +	writel(can_id, &regs->cantxfg[TX_BUF_ID].can_id);

Are you sure, that this is correct?

Indeed i wonder, if it would make sense to skip the entire struct flexcan_mb
approach and fiddle byte-by-byte inside the registers ...

Regards,
Oliver
