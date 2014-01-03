From: David Miller <davem@davemloft.net>
Subject: Re: =?iso-2022-jp-3?B?GyRCRXobJChQJTsbKEI6?= Re: [Patch]
 netxen_nic: Bugfix for wrong RUNNING status of NX3031 NICs with no link
Date: Fri, 03 Jan 2014 02:18:31 -0500 (EST)
Message-ID: <20140103.021831.1305273132366498641.davem@davemloft.net>
References: <1388685624.9947.7.camel@bwh-desktop.uk.level5networks.com>
	<OF9AC42061.4BF09F2E-ON48257C55.00253C5A-48257C55.0027274D@zte.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, li.fengmao@zte.com.cn,
	manish.chopra@qlogic.com, netdev@vger.kernel.org,
	rajesh.borundia@qlogic.com, sony.chacko@qlogic.com,
	wang.liang82@zte.com.cn, cai.qu@zte.com.cn, long.chun@zte.com.cn
To: jiang.biao2@zte.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaACHSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 02:18:33 -0500
In-Reply-To: <OF9AC42061.4BF09F2E-ON48257C55.00253C5A-48257C55.0027274D@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jiang.biao2@zte.com.cn
Date: Fri, 3 Jan 2014 15:07:27 +0800

> netif_carrier_off();
> netdev->operstate=IF_OPER_DOWN;
> register_netdevice();

This is too gross for words.

Stop fighting the way that device registraction and initial carrier
state works, please.
