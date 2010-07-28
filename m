From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/3] stmmac: fix timer setup when use dual mac
 Kconfig
Date: Tue, 27 Jul 2010 20:46:03 -0700 (PDT)
Message-ID: <20100727.204603.184850135.davem@davemloft.net>
References: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
	<1280225387-26240-2-git-send-email-peppe.cavallaro@st.com>
	<20100727.204528.149852941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48827
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753820Ab0G1Dpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 23:45:45 -0400
In-Reply-To: <20100727.204528.149852941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 27 Jul 2010 20:45:28 -0700 (PDT)

Sorry, I meant to say this in reply to patch #1 not #2 :)

> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue, 27 Jul 2010 12:09:46 +0200
> 
>> The driver erroneously sets the tmrate to zero when the
>> TMU initialisation fails. This actually generates problems
>> while using the dual GMAC configuration.
>> 
>> With this patch, enabling both the dual gmac and the timer
>> optimisation, the first interface opened will use the tmu
>> channel 2, the second one won't be able to use the timer but
>> will continue to work without mitigating the interrupts by
>> using the external timer (i.e. TMU channel 2).
>> 
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> This is not how we do things.
> 
> All of the options that influence the driver should be right next
> to the main driver option.
> 
> What the platform SOC Kconfig's can do is 'select' those option.
> 
> But even better is to get rid of all of these feature Kconfig options,
> and communicate the capability in the platform_device probe
> information or similar.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
