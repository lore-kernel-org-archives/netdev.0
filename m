From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Fix frame size warning for 32 bit arch
Date: Wed, 25 Mar 2015 11:45:47 -0400 (EDT)
Message-ID: <20150325.114547.128768732000647112.davem@davemloft.net>
References: <1427293886-7859-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203AbbCYPpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:45:49 -0400
In-Reply-To: <1427293886-7859-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 25 Mar 2015 20:01:26 +0530

> Fixes below warning by dynamically allocating memory
> 
> All warnings:
> 
>    drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c: In function
>    'cctrl_tbl_show':
>    >> drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c:689:1: warning: the
>    >> frame
>    >> size of 1028 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
