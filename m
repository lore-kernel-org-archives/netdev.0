From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 1/6] stmmac: disable at run-time the EEE if
 not supported
Date: Wed, 26 Feb 2014 07:39:30 +0100
Message-ID: <530D8C22.2020703@st.com>
References: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com> <530CC4E4.40301@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:52094 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbaBZGje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 01:39:34 -0500
In-Reply-To: <530CC4E4.40301@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/2014 5:29 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 25-02-2014 13:58, Giuseppe Cavallaro wrote:
>
>> This patch is to disable the EEE (so HW and timers)
>> for example when the phy communicates that the EEE
>> can be supported anymore.
>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   24
>> ++++++++++++++++----
>>   1 files changed, 19 insertions(+), 5 deletions(-)
>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 078ad0e..dc89dc3 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> [...]
>> @@ -2204,7 +2219,6 @@ static int stmmac_poll(struct napi_struct *napi,
>> int budget)
>>   static void stmmac_tx_timeout(struct net_device *dev)
>>   {
>>       struct stmmac_priv *priv = netdev_priv(dev);
>> -
>
>     Why? Empty line is needed here, after declaration.

yes out-of-scope in this patch. I'll fix it and resend all

BR
Peppe

>
>>       /* Clear Tx resources and restart transmitting again */
>>       stmmac_tx_err(priv);
>>   }
>
> WBR, Sergei
>
>
>
