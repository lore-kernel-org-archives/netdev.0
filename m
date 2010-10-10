From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add IRQF_SAMPLE_RANDOM Flag to forcedeth
Date: Sat, 09 Oct 2010 20:15:01 -0700 (PDT)
Message-ID: <20101009.201501.214209347.davem@davemloft.net>
References: <4CB0FEA6.3030206@netscape.net>
	<20101010010924.GB15074@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxrocks123@netscape.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39129
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757052Ab0JJDOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 23:14:40 -0400
In-Reply-To: <20101010010924.GB15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 10 Oct 2010 02:09:24 +0100

> Patrick Simmons wrote:
>> This patch adds the IRQF_SAMPLE_RANDOM flag to the forcedeth driver, 
>> allowing the interrupt timing for forcedeth to be used for entropy 
>> generation.  This should help /dev/random generate more secure random 
>> numbers on machines using this driver.
> [...]
> 
> We don't enable this for network drivers any more because:
> 
> 1. At high packet rates, interrupt moderation makes interrupts very
> regular.
> 2. At low packet rates, a malicious sender can control the interrupt
> timing.

Agreed on all counts, I'm not applying this patch.
