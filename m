From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/15] add missing of_node_put after calling
 of_parse_phandle
Date: Mon, 01 Aug 2016 22:14:44 -0700 (PDT)
Message-ID: <20160801.221444.382083420333834306.davem@davemloft.net>
References: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbridger@opensource.altera.com,
	isubramanian@apm.com, kchudgar@apm.com, yisen.zhuang@huawei.com,
	salil.mehta@huawei.com, thomas.petazzoni@free-electrons.com,
	sergei.shtylyov@cogentembedded.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, mugunthanvnm@ti.com, tremyfr@gmail.com,
	wxt@rock-chips.com, arnd@arndb.de, david.daney@cavium.com,
	huangdaode@hisilicon.com, jszhang@marvell.com
To: peter.chen@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbcHBF0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 01:26:04 -0400
In-Reply-To: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chen <peter.chen@nxp.com>
Date: Mon, 1 Aug 2016 15:02:28 +0800

> This patch set fixes missing of_node_put issue at ethernet driver.
> of_node_put needs to be called when the device node which is got
> from of_parse_phandle has finished using.
> 
> The compilation test has passed by using allmodconfig for drivers/net/ethernet.
> 
> Thanks.
> 
> Changes for v2:
> - If the device node is local variable, it can be put in the same function.
> - If the device node will be used the whole driver life cycle,
>   it should be put (call of_node_put) at driver's remove. 
>   Patch [4, 5, 9, 14, 15/15]
> - Fix the issue that the node still be used at error patch [6/15]
> - Add acked for patch [11,12/15]

Series applied, thanks.
