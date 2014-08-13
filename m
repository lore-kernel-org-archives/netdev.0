From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] libcxgbi/cxgb4i : Fix ipv6 build failure caught
 with randconfig
Date: Wed, 13 Aug 2014 16:30:50 -0700 (PDT)
Message-ID: <20140813.163050.184581332441300083.davem@davemloft.net>
References: <1407908306-10790-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hch@infradead.org, kxie@chelsio.com,
	manojmalviya@chelsio.com, jim.epost@gmail.com, sfr@canb.auug.org.au
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbaHMXav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 19:30:51 -0400
In-Reply-To: <1407908306-10790-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 12 Aug 2014 22:38:26 -0700

> Previous guard of IS_ENABLED(CONFIG_IPV6) is not sufficient when cxgbi drivers
> are built into kernel but ipv6 is not.
> 
> v2: Use Kconfig to disable compiling cxgbi built into kernel when ipv6 is
> compiled as a module
> 
> Fixes: e81fbf6cd652 ("libcxgbi:cxgb4i Guard ipv6 code with a config check")
> Fixes: fc8d0590d914 ("libcxgbi: Add ipv6 api to driver")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

This looks better, applied, thanks.
