From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 1/1] drivers: net: davinci_cpdma: acknowledge interrupt
 properly
Date: Sun, 17 Feb 2013 15:04:42 +0530
Message-ID: <5120A432.5070302@ti.com>
References: <1360866406-17261-1-git-send-email-mugunthanvnm@ti.com> <20130215.150506.499818568035818118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:60553 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755420Ab3BQJey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2013 04:34:54 -0500
In-Reply-To: <20130215.150506.499818568035818118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/2013 1:35 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Thu, 14 Feb 2013 23:56:46 +0530
>
>> +enum {
>> +	CPDMA_EOI_RX_THRESH = 0,
>> +	CPDMA_EOI_RX,
>> +	CPDMA_EOI_TX,
>> +	CPDMA_EOI_MISC,
>> +};
> Do not use enumerations for hardware register values, which must be
> exact, otherwise you are potentially going to succumb to the vagaries
> of C language enumeration value assignment.
Will change enum to define and submit next version patch.

Regards
Mugunthan V N
