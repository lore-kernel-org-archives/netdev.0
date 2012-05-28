From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net] stmmac: fix driver Kconfig when built as module
Date: Mon, 28 May 2012 07:44:40 +0200
Message-ID: <4FC310C8.3000300@st.com>
References: <1337672336-7378-2-git-send-email-lliubbo@gmail.com> <1337753142-13762-1-git-send-email-peppe.cavallaro@st.com> <20120523.140139.197296963542601285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	lliubbo@gmail.com, rayagond@vayavyalabs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:57376 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210Ab2E1FpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 01:45:11 -0400
In-Reply-To: <20120523.140139.197296963542601285.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/2012 8:01 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Wed, 23 May 2012 08:05:42 +0200
> 
>> This patches fixes the driver when built as dyn module.
>> In fact the platform part cannot be built and the probe fails
>> (thanks to Bob Liu that reported this bug).
>> The patch also makes the selection of Platform and PCI parts
>> mutually exclusive.
>>
>> Reported-by: Bob Liu <lliubbo@gmail.com>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> We have drivers which support both OF (which is implemented as
> platform bus) and PCI at the same time.  For example,
> drivers/net/ethernet/sun/niu.c
> 
> I do not see why stmmac cannot support both at the same time as well.
> 
> I absolutely do not want such segregation unless it is absolutely
> necessary.  Because it means that no matter what is choosen, a piece
> of code is disabled and therefore not getting build and/or runtime
> validation.

Ok, I'll review it and resend all the patches asap.

Regards
Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
