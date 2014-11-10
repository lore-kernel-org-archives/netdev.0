From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/3] RDMA/cxgb4,cxgb4vf,cxgb4i,csiostor:
 Cleanup macros
Date: Mon, 10 Nov 2014 12:57:42 -0500 (EST)
Message-ID: <20141110.125742.1453978794920057126.davem@davemloft.net>
References: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	praveenm@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbaKJSGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 13:06:06 -0500
In-Reply-To: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  7 Nov 2014 09:35:22 +0530

> This series moves the debugfs code to a new file debugfs.c and cleans up
> macros/register defines.
> 
> Various patches have ended up changing the style of the symbolic macros/register
> defines and some of them used the macros/register defines that matches the
> output of the script from the hardware team.
> 
> As a result, the current kernel.org files are a mix of different macro styles.
> Since this macro/register defines is used by five different drivers, a
> few patch series have ended up adding duplicate macro/register define entries
> with different styles. This makes these register define/macro files a complete
> mess and we want to make them clean and consistent.
> 
> Will post few more series so that we can cover all the macros so that they all
> follow the same style to be consistent.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4, cxgb4vf, iw_cxgb4, csiostor and cxgb4i driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.
 ...
> V3: Use suffix instead of prefix for macros/register defines
> V2: Changes the description and cover-letter content to answer David Miller's
> question

Series applied, thanks.
