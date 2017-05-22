From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/11] qede: Fix sparse warnings
Date: Mon, 22 May 2017 14:29:03 -0400 (EDT)
Message-ID: <20170522.142903.2151382146475588141.davem@davemloft.net>
References: <BLUPR0701MB2004062F133B0DD22E817C6C8DF80@BLUPR0701MB2004.namprd07.prod.outlook.com>
        <20170522.125430.1296201768191613727.davem@davemloft.net>
        <BLUPR0701MB20043F202421D02E697198338DF80@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Manish.Chopra@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933452AbdEVS3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:29:05 -0400
In-Reply-To: <BLUPR0701MB20043F202421D02E697198338DF80@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Mon, 22 May 2017 17:44:12 +0000

>> >> Please.
>> >> 
>> >> This is exactly the problem when such a terse commit message, or lack of any
>> >> message at all as is the case here, occurs.
>> >> 
>> >> I have no idea what removing this method assignment has to do with fixing
>> >> sparse warnings.
>> > 
>> > It's currently defined twice in the qede_dcbnl_ops struct -
> 
>> >Ok, so what's important is that you don't just post a patch with no
>> commit message, just saying "sparse warning fixes."
> 
>> At a minimum, if you're too lazy to explain what exactly each thing
>> is fixing, provide the sparse warnings you are eliminating in the
>> commit message.
> 
> Well, this time it was intentional lazines; Thought it would have been
> wasted reading. But sure, here it is:
> 
> drivers/net/ethernet/qlogic/qede/qede_fp.c:349:34: warning: invalid assignment: |=
> drivers/net/ethernet/qlogic/qede/qede_fp.c:349:34:    left side has type restricted __le16
> drivers/net/ethernet/qlogic/qede/qede_fp.c:349:34:    right side has type int
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1516:50: warning: invalid assignment: |=
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1516:50:    left side has type restricted __le16
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1516:50:    right side has type int
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1525:50: warning: invalid assignment: ^=
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1525:50:    left side has type restricted __le16
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1525:50:    right side has type int
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1590:42: warning: invalid assignment: |=
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1590:42:    left side has type restricted __le16
> drivers/net/ethernet/qlogic/qede/qede_fp.c:1590:42:    right side has type unsigned int
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1315:34: warning: invalid assignment: |=
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1315:34:    left side has type restricted __le16
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1315:34:    right side has type int
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1330:13: warning: incorrect type in assignment (different base types)
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1330:13:    expected int [signed] [assigned] val
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1330:13:    got restricted __le16 [usertype] <noident>
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1331:33: warning: incorrect type in assignment (different base types)
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1331:33:    expected restricted __le16 [usertype] bd_prod
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1331:33:    got int [signed] [assigned] val
> drivers/net/ethernet/qlogic/qede/qede_roce.c:224:29: warning: symbol 'qede_roce_get_free_event_node' was not declared. Should it be static?
> 
> Do you want us to re-spin the series with the updated commit message?

Where in that log above does it say that the method is defined twice
in qede_dcbnl_ops?

I hate to say this, but this is why I get frustrated with such across
the board cleanups with empty commit messages.
