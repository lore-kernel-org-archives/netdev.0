From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Don't enable RX Filer if not supported
Date: Wed, 16 Dec 2015 18:31:55 -0500 (EST)
Message-ID: <20151216.183155.1166436702361116871.davem@davemloft.net>
References: <1450142090-10411-1-git-send-email-hamish.martin@alliedtelesis.co.nz>
	<SN1PR0301MB2046E539353A8295C56340E79CEE0@SN1PR0301MB2046.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hamish.martin@alliedtelesis.co.nz, netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbbLPXb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 18:31:57 -0500
In-Reply-To: <SN1PR0301MB2046E539353A8295C56340E79CEE0@SN1PR0301MB2046.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manoil Claudiu <claudiu.manoil@freescale.com>
Date: Tue, 15 Dec 2015 10:12:36 +0000

>>-----Original Message-----
>>From: Hamish Martin [mailto:hamish.martin@alliedtelesis.co.nz]
>>Sent: Tuesday, December 15, 2015 3:15 AM
>>To: Manoil Claudiu-B08782 <claudiu.manoil@freescale.com>
>>Cc: netdev@vger.kernel.org; Hamish Martin
>><hamish.martin@alliedtelesis.co.nz>
>>Subject: [PATCH] gianfar: Don't enable RX Filer if not supported
>>
>>After commit 15bf176db1fb ("gianfar: Don't enable the Filer w/o the
>>Parser"), 'TSEC' model controllers (for example as seen on MPC8541E)
>>always have 8 bytes stripped from the front of received frames.
>>Only 'eTSEC' gianfar controllers have the RX Filer capability (amongst
>>other enhancements). Previously this was treated as always enabled
>>for both 'TSEC' and 'eTSEC' controllers.
>>In commit 15bf176db1fb ("gianfar: Don't enable the Filer w/o the Parser")
>>a subtle change was made to the setting of 'uses_rxfcb' to effectively
>>always set it (since 'rx_filer_enable' was always true). This had the
>>side-effect of always stripping 8 bytes from the front of received frames
>>on 'TSEC' type controllers.
>>
>>We now only enable the RX Filer capability on controller types that
>>support it, thereby avoiding the issue for 'TSEC' type controllers.
>>
> 
> 
> Reviewed-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied and queued up for -stable, thanks everyone.
