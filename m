From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] cxgb4: Fix for SR-IOV VF initialization
Date: Wed, 06 Aug 2014 13:47:33 -0700 (PDT)
Message-ID: <20140806.134733.1403352639265928198.davem@davemloft.net>
References: <1407325259-1637-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaHFUrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 16:47:37 -0400
In-Reply-To: <1407325259-1637-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  6 Aug 2014 17:10:59 +0530

> Commit 35b1de5 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is exposed
> through PCI Passthrough") introduced a regression, where VF failed to
> initialize for Physical function 0 to Physical Function 3. In the above
> commit, we removed the code which used to enable sriov for PF0 to PF3. Now
> adding it back to get sriov working.
> 
> V2:
>  Removed SRIOV loop for PF[0..3] to instantiate the VF's as per David Miller's
>  comment
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
