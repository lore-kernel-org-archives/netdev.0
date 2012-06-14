From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 1/4 (v5)] phy: add the EEE support and the way
 to access to the MMD registers.
Date: Thu, 14 Jun 2012 12:51:11 +0200
Message-ID: <4FD9C21F.1030208@st.com>
References: <1339574463-1207-1-git-send-email-peppe.cavallaro@st.com>  <1339574463-1207-2-git-send-email-peppe.cavallaro@st.com> <1339630137.2612.83.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:34271 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755197Ab2FNKvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 06:51:23 -0400
In-Reply-To: <1339630137.2612.83.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/14/2012 1:28 AM, Ben Hutchings wrote:
> On Wed, 2012-06-13 at 10:01 +0200, Giuseppe CAVALLARO wrote:
>> This patch adds the support for the Energy-Efficient Ethernet (EEE)
>> to the Physical Abstraction Layer.
>> To support the EEE we have to access to the MMD registers 3.20 and
>> 7.60/61. So two new functions have been added to read/write the MMD
>> registers (clause 45).
>>
>> An Ethernet driver (I tested the stmmac) can invoke the phy_init_eee to properly
>> check if the EEE is supported by the PHYs and it can also set the clock
>> stop enable bit in the 3.0 register.
>> The phy_get_eee_err can be used for reporting the number of time where
>> the PHY failed to complete its normal wake sequence.
>>
>> In the end, this patch also adds the EEE ethtool support implementing:
>>  o phy_ethtool_set_eee
>>  o phy_ethtool_get_eee
>>
>> v1: initial patch
>> v2: fixed some errors especially on naming convention
>> v3: renamed again the mmd read/write functions thank to Ben's feedback
>> v4: moved file to phy.c and added the ethtool support.
>> v5: fixed phy_adv_to_eee, phy_eee_to_supported, phy_eee_to_adv return
>>     values according to ethtool API (thanks to Ben's feedback).
>>     Renamed some macros to avoid too long names.
> 
> Sorry, I spotted some more little issues:

No problem, I'll fix these too.

Many thanks
Regards
Peppe
