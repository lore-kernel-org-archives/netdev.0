From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] SR-IOV and FW-dump enhancements
Date: Fri, 09 May 2014 13:10:32 -0400 (EDT)
Message-ID: <20140509.131032.985580944351594696.davem@davemloft.net>
References: <1399618293-28633-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757138AbaEIRKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:10:34 -0400
In-Reply-To: <1399618293-28633-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Fri, 9 May 2014 02:51:28 -0400

> This patch series contain following enhancements.
> 
> * SR-IOV enhancements:
>  - Allow SR-IOV VF's to probe in hypervisor. SR-IOV VF can be
>    uplinked to bridge/macvtap device with this change.
>  - Commands from VF are processed in process context
>    as it may sleep during PF-VF communication. Earlier
>    we use to process qlcnic_sriov_vf_set_multi function in 
>    process context but now we process individual commands.
>  - As SR-IOV VF's can be uplinked to bridge/macvtap device
>    support mac-learning to allow communication through 
>    embedded switch.
> 
> * FW-dump enhancement:
>  - Support to collect RDMEM section of firmware dump using 
>    PEX DMA method for 82xx series adapter. 
> 
> * Changes in v2:
>  - Removed unnecessary cast from void pointer to something
>    else and verified this issue in entire patch series as
>    per David Miller's suggestion.
> 
> Please apply this series to net-next.

Series applied, thanks.
