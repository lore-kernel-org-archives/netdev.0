From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/7] qed*: Rename qede_roce.[ch]
Date: Fri, 16 Jun 2017 11:44:28 -0400 (EDT)
Message-ID: <20170616.114428.630059630310905770.davem@davemloft.net>
References: <20170615202933.20934-5-Yuval.Mintz@cavium.com>
        <201706160552.EYIdXcuM%fengguang.wu@intel.com>
        <BLUPR0701MB2004F40778215AD277D4FF348DC10@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, kbuild-all@01.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, Michal.Kalderon@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60392 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdFPPoa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 11:44:30 -0400
In-Reply-To: <BLUPR0701MB2004F40778215AD277D4FF348DC10@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Fri, 16 Jun 2017 12:41:15 +0000

>>    In file included from drivers/net//ethernet/qlogic/qede/qede.h:43:0,
>>                     from drivers/net//ethernet/qlogic/qede/qede_ptp.h:38,
>>                     from drivers/net//ethernet/qlogic/qede/qede_fp.c:43:
>> >> include/linux/qed/qede_rdma.h:57:12: warning: 'struct pci_dev' declared
>> inside parameter list [enabled by default]
>> >> include/linux/qed/qede_rdma.h:57:12: warning: its scope is only this
>> definition or declaration, which is probably not what you want [enabled by
>> default]
> 
> This patch is merely renaming qede_roce.h -> qede_rdma.h.
> I guess the kbuild test robot got better scripts than the time we've added qede_rdma.h,
> or else it would have catched the fact there are no inclusion since then.
> 
> Dave - given this is an existing warning exposed due to a rename [and not something
> that actually got introduced in this patch], do you want us to fix it via v2 of this series?
> Or send a fix for it later?

I don't know, look at what you're doing in main.c, you're removing an include
rather than changing the name of the file being included.

That is not a zero-change rename at all.

Please respin this and fix all of the things the build bot is reporting as
well as what I just mentioned.

Thank you.
