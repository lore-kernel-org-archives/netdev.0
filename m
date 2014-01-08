From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 1/2] cxgb4: Fix namespace collision issue.
Date: Wed, 8 Jan 2014 16:49:24 +0530
Message-ID: <20140108111923.GA15969@hariprasad-pc>
References: <1389094088-6261-1-git-send-email-hariprasad@chelsio.com>
 <1389094088-6261-2-git-send-email-hariprasad@chelsio.com>
 <20140107.154813.1483946457674959301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<nirranjan@chelsio.com>, <kumaras@chelsio.com>,
	<santosh@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29084 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639AbaAHLSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 06:18:51 -0500
Content-Disposition: inline
In-Reply-To: <20140107.154813.1483946457674959301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 15:48:13 -0500, David Miller wrote:
> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Tue,  7 Jan 2014 16:58:07 +0530
> 
> > Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
>   ...
> 
> > -int t4_init_tp_params(struct adapter *adap)
> 
> There is no reason that an already exported function must be moved
> to solve a namespace issue.
> 
> If you want to move this function for another reason, fine, but do
> it in a seperate change with a clear description of that reason in
> your commit message.
> 
> I'm not applying this series.

I will drop this patch series. I will send an independent patch for FW version
check.
