From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make snmp_mib_free static inline
Date: Mon, 02 Sep 2013 21:01:36 -0700 (PDT)
Message-ID: <20130902.210136.1526840017952963809.davem@davemloft.net>
References: <1378087613-15279-1-git-send-email-amwang@redhat.com>
	<1378087613-15279-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab3ICDzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 23:55:31 -0400
In-Reply-To: <1378087613-15279-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  2 Sep 2013 10:06:53 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Fengguang reported:
> 
>    net/built-in.o: In function `in6_dev_finish_destroy':
>    (.text+0x4ca7d): undefined reference to `snmp_mib_free'
> 
> this is due to snmp_mib_free() is defined when CONFIG_INET is enabled,
> but in6_dev_finish_destroy() is now moved to core kernel.
> 
> I think snmp_mib_free() is small enough to be inlined, so just make it
> static inline.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
