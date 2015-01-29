From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Remove preprocessor check for CONFIG_CXGB4_DCB
Date: Thu, 29 Jan 2015 15:10:30 -0800 (PST)
Message-ID: <20150129.151030.621632674659139306.davem@davemloft.net>
References: <1422461991-20684-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbA2XKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:10:31 -0500
In-Reply-To: <1422461991-20684-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 28 Jan 2015 21:49:51 +0530

> In commit dc9daab226aa ("cxgb4: Added support in debugfs to dump
> sge_qinfo") a preprocessor check for CONFIG_CXGB4_DCB got added, which should
> have been CONFIG_CHELSIO_T4_DCB.
> 
> Reported-by: Paul Bolle <pebolle@tiscal.nl>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

That's not all this patch is doing:

> +static inline struct port_info *ethqset2pinfo(struct adapter *adap, int qset)

You need to explain why this function needs to be added in the
commit message.

I can see myself that the build fails without it because you
forgot to add it in the original commit, or someone removed
it meanwhile, but you have to say so in the commit message
so everyone can understand.
