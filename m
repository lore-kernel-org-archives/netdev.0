From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phy_device: Interrupt number 0 is valid
Date: Thu, 09 Oct 2008 10:05:03 +0300
Message-ID: <48EDAD1F.6010109@teltonika.lt>
References: <48ECA4A0.7080508@teltonika.lt> <20081008.094335.216774973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:37148 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754703AbYJIHFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 03:05:08 -0400
In-Reply-To: <20081008.094335.216774973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Date: Wed, 08 Oct 2008 15:16:32 +0300
> 
>> If interrupt number 0(valid interrupt number) will be passed as
>> phy interrupt it should be used. In current situation even phy
>> polling will not work since PHY_POLL = -1
>>
>> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> 
> In the Linux kernel, interrupt number 0 is defined as not valid.

Where it is defined as not valid?
Maybe it is not valid under x86, but it is valid at least on
ARM for sure.
Anyway if interrupt 0 is not valid then request_irq() will fail
and PHY_POLL will be used.
