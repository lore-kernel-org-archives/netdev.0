From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: ethernet: stmicro: stmmac: Fix compile error when
 STMMAC_XMIT_DEBUG used
Date: Thu, 13 Jun 2013 11:56:33 +0200
Message-ID: <51B99751.6050006@st.com>
References: <1371053103-13536-1-git-send-email-dinguyen@altera.com> <20130613.013152.180392586047160961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dinguyen@altera.com, netdev@vger.kernel.org, dinh.linux@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:33913 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758601Ab3FMJ6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:58:11 -0400
In-Reply-To: <20130613.013152.180392586047160961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David
On 6/13/2013 10:31 AM, David Miller wrote:
> From: <dinguyen@altera.com>
> Date: Wed, 12 Jun 2013 11:05:03 -0500
>
>> From: Dinh Nguyen <dinguyen@altera.com>
>>
>> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function:
>> stmmac_xmit drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1902:74:
>> error: expected ) before __func__
>>
>> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> CC: David S. Miller <davem@davemloft.net>
>
> Applied, but this debugging mechanism is completely unacceptable.

I agree with you, I do not like it too

this debug code is quite old and fixed to the initial driver version.
I had used it to the initial debug so I must rework it (also because
debug has to be guarantee w/o errors and w/o ifdef proliferation)

I'll prepare a patch asap.

Peppe

>
> We have a dynamic, run time, way to do stuff like this without
> peppering up a driver with gross ifdefs.
>
> This driver must be converted over to use "netif_msg_*()" et al.
> to guard message logging of different types of events.
>
>
