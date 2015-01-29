From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_connmark: fix dependencies better
Date: Wed, 28 Jan 2015 23:23:28 -0800 (PST)
Message-ID: <20150128.232328.1976350674232200974.davem@davemloft.net>
References: <1806649.OoZh1UV3MM@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, nbd@openwrt.org,
	jhs@mojatatu.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbbA2HX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 02:23:29 -0500
In-Reply-To: <1806649.OoZh1UV3MM@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 28 Jan 2015 17:30:09 +0100

> NET_ACT_CONNMARK fails to build if NF_CONNTRACK_MARK is disabled,
> and d7924450e14ea4 ("act_connmark: Add missing dependency on
> NF_CONNTRACK_MARK") fixed that case, but missed the cased where
> NF_CONNTRACK is a loadable module.
> 
> This adds the second dependency to ensure that NET_ACT_CONNMARK
> can only be built-in if NF_CONNTRACK is also part of the kernel
> rather than a loadable module.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
