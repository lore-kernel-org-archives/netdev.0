From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/3] stmmac: fix NULL pointer dereference in capabilities
 fixup
Date: Thu, 27 Oct 2011 07:36:07 +0200
Message-ID: <4EA8EDC7.7020305@st.com>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>  <1319637339-14866-2-git-send-email-peppe.cavallaro@st.com> <1319668008.6759.2.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keguang.zhang@gmail.com,
	Angus Clark <angus.clark@st.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:50822 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751405Ab1J0FgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 01:36:13 -0400
In-Reply-To: <1319668008.6759.2.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2011 12:26 AM, Ben Hutchings wrote:
> On Wed, 2011-10-26 at 15:55 +0200, Giuseppe CAVALLARO wrote:
>> From: Angus Clark <angus.clark@st.com>
>>
>> Signed-off-by: Angus Clark <angus.clark@st.com>
>> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index fcdd5a2..f77eaa6 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -325,7 +325,7 @@ static int stmmac_init_phy(struct net_device *dev)
>>  	    (interface == PHY_INTERFACE_MODE_RMII))) {
>>  		phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
>>  				      SUPPORTED_Asym_Pause);
>> -		priv->phydev->advertising = priv->phydev->supported;
>> +		priv->phydev->advertising = phydev->supported;
> 
> How can this fix the bug?  You mean:
> 
> 		phydev->advertising = phydev->supported;

Ben, you are rigth.
I did a mistake importing the patch from Angus.

I'm fixing and resending it again.

Thanks and Sorry
Peppe

> 
> Ben.
> 
>>  	}
>>  
>>  	/*
> 
