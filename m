From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 2/8] test_bitmap: unit tests for lib/bitmap.c
Date: Thu, 18 Feb 2016 14:00:08 -0500 (EST)
Message-ID: <20160218.140008.1645431745407584155.davem@davemloft.net>
References: <1455625964-8943-1-git-send-email-kan.liang@intel.com>
	<1455625964-8943-3-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bwh@kernel.org, ben@decadent.org.uk,
	andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947336AbcBRTAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:00:15 -0500
In-Reply-To: <1455625964-8943-3-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>
Date: Tue, 16 Feb 2016 07:32:38 -0500

> @@ -43,6 +43,7 @@ obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
>  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_keys.o
>  obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_key_base.o
>  obj-$(CONFIG_TEST_PRINTF) += test_printf.o
> +obj-$(CONFIG_TEST_BITMAP) += test_bitmap.o
 ...
>  
> -TEST_PROGS := printf.sh
> +TEST_PROGS := printf.sh bitmap.sh

I see neither test_bitmap.c nor bitmap.sh in this patch, perhaps some
forgotten git add commands?
