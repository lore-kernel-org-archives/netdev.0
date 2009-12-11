From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH] gianfar: Fix a filer bug
Date: Fri, 11 Dec 2009 10:14:48 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08B34@zin33exm22.fsl.freescale.net>
References: <1260366911-15178-1-git-send-email-Sandeep.Kumar@freescale.com> <20091210150712.GA17851@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:64411 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933372AbZLKEox convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 23:44:53 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBB4iw9d016666
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 21:44:58 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id nBB4o3gw018764
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 22:50:04 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091210150712.GA17851@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>[...]
>> -	if (priv->rx_filer_enable)
>> +	if (priv->rx_filer_enable) {
>>  		rctrl |= RCTRL_FILREN;
>> +		/* Program the RIR0 reg with the required 
>distribution */
>> +		regs->rir0 = DEFAULT_RIR0;
>
>You cannot access regs directly. You have to use gfar_write 
>since regs is ioremapped memory.
>

Yes. I will send out the patch with the required change.

--

Thanks
Sandeep
