From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.3.0] phy:icplus:fix Auto Power Saving in
 ip101a_config_init.
Date: Wed, 09 May 2012 11:57:29 -0400 (EDT)
Message-ID: <20120509.115729.1982766903625560504.davem@davemloft.net>
References: <1333360929-31506-1-git-send-email-srinivas.kandagatla@st.com>
	<20120403.184937.744089580257691570.davem@davemloft.net>
	<20120509072537.GA437@burratino>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: srinivas.kandagatla@st.com, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: jrnieder@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108Ab2EIP5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 11:57:38 -0400
In-Reply-To: <20120509072537.GA437@burratino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Nieder <jrnieder@gmail.com>
Date: Wed, 9 May 2012 02:25:37 -0500

> Hi Dave,
> 
> David Miller wrote:
>> From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
> 
>>> This patch fixes Auto Power Saving configuration in ip101a_config_init
>>> which was broken as there is no phy register write followed after
>>> setting IP101A_APS_ON flag.
>>>
>>> This patch also fixes the return value of ip101a_config_init.
>>>
>>> Without this patch ip101a_config_init returns 2 which is not an error
>>> accroding to IS_ERR and the mac driver will continue accessing 2 as
>>> valid pointer to phy_dev resulting in memory fault.
>>>
>>> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>>
>> Applied and queued up for -stable, thanks.
> 
> I'm guessing 3.2.y needs this, too, since it also includes
> v3.2-rc1~129^2~247 ("net/phy: add IC+ IP101A and support APS").
> 
> Here's a quick backport made by adjusting the context line to
> use IP101A_APS_ON instead of IP101A_G_APS_ON.
> 
> Please include it in some later stable update if appropriate.

Please submit this directly to the stable list.
