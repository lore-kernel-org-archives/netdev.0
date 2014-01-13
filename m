From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] qlcnic driver updates
Date: Mon, 13 Jan 2014 15:32:55 -0800 (PST)
Message-ID: <20140113.153255.182055320418133623.davem@davemloft.net>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbaAMXc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 18:32:56 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Fri, 10 Jan 2014 11:48:51 -0500

> This series includes following changes:
> o SRIOV and VLAN filtering related enhancements which includes
>    - Do MAC learning for PF
>    - Restrict VF from configuring any VLAN mode
>    - Enable flooding on PF
>    - Turn on promiscuous mode for PF
> 
> o Bug fix in qlcnic_sriov_cleanup() introduced by commit
>   154d0c81("qlcnic: VLAN enhancement for 84XX adapters")
> 
> o Beaconing support for 83xx and 84xx series adapters
> 
> o Allow 82xx adapter to perform IPv6 LRO even if destination IP address is not
>   programmed.
> 
> Please apply this series to net-next.

Series applied, but you really should make rx_mac_learn a bool just
like drv_mac_learn and fdb_mac_learn already are.
