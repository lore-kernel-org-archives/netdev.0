From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 5/6] stmmac: remove useless check in the stmmac_tx_clean
Date: Thu, 27 Feb 2014 10:59:01 +0100
Message-ID: <530F0C65.4080905@st.com>
References: <1393401667-6452-1-git-send-email-peppe.cavallaro@st.com>	<1393401667-6452-6-git-send-email-peppe.cavallaro@st.com> <20140226.161422.431061479377150157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:46458 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058AbaB0J7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 04:59:08 -0500
In-Reply-To: <20140226.161422.431061479377150157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/26/2014 10:14 PM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Wed, 26 Feb 2014 09:01:06 +0100
>
>> There is an useless if condition that this patch is removing
>> when the driver cleans the tx resources.
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>
> It is not useless, the first check is optimistic and lock free.
>
> You must retest the condition under the lock in order to avoid
> spurious wakeups.
>
> Such a spurious wakeup could overlap another asynchronous context
> filling the TX queue and sleeping it, resulting in corruption.
>
> Furthermore, that cleanup patch in this series is absolutely not
> appropriate for 'net' which is for real bug fixes only.  Specifically
> I'm talking about patch #4.
>
>

Ok  I will send the patches w/o the #4. Thx for your advice

peppe
