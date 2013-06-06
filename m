From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH v4 0/5] Adding pinctrl PM support for CPSW and
 MDIO
Date: Thu, 6 Jun 2013 13:57:25 +0530
Message-ID: <51B047ED.5060203@ti.com>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com> <51B03D4E.3090504@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	<benoit.cousson@linaro.org>, <linux-omap@vger.kernel.org>,
	<davem@davemloft.net>
To: Benoit Cousson <b-cousson@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:37890 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab3FFI1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 04:27:33 -0400
In-Reply-To: <51B03D4E.3090504@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/6/2013 1:12 PM, Benoit Cousson wrote:
> Hi Mugunthan,
>
> On 06/05/2013 07:08 PM, Mugunthan V N wrote:
>> This patch series adds the following features
>> * Adding pinctrl PM support for CPSW and MDIO for Power Optimization
>> * Adding phy address to the CPSW node for EVMsk board
>>
>> Changes from initial version
>> * Fixed the multiline function call indentation as per David Miller
>>    recommendation.
>>
>> Changes from v2
>> * Fixed the multi comment style as per net coding style
>> * Fixed checkpatch error (more than 80 characters)
>>
>> Changes from v3
>> * Removed below patch as it has already merged to net-next
>> 	ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
>> * Rebased to net-next as there was a merge conflict in DT files
> You should try to avoid pushing DTS patches outside the arm-soc tree, it
> will generate a bunch a conflict when arm-soc and net trees will be merged.
>
> Could you post separately all the DTS patches and rebase them on the
> for_3.11/dts branch that already contains a bunch of AM33xx patches?
Benoit

Will separate out the DT patches and will submit on top of for_3.11/dts 
today as v5.

Regards
Mugunthan V N
