From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/2] stmmac: request_irq when use an ext wake irq line
Date: Fri, 10 Feb 2012 07:31:21 +0100
Message-ID: <4F34B9B9.5090803@st.com>
References: <1328774114-28894-1-git-send-email-peppe.cavallaro@st.com> <20120209.140251.1155907203355431647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:34014 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752961Ab2BJGb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 01:31:29 -0500
In-Reply-To: <20120209.140251.1155907203355431647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/9/2012 8:02 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Thu,  9 Feb 2012 08:55:13 +0100
> 
>> From: Francesco Virlinzi <francesco.virlinzi@st.com>
>>
>> In case of we use an external Wake-Up IRQ line
>> (priv->wol_irq != dev->irq) we need to invoke the
>> request_irq.
>>
>> Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> You never free the IRQ in the driver close path, so it leaks.

Yes you are right. I'm reviewing the patch and send it again.
Thx
peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
