From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] IP_GRE: Fix GRE_CSUM case.
Date: Mon, 25 Feb 2013 15:48:18 -0500 (EST)
Message-ID: <20130225.154818.1842913863630535011.davem@davemloft.net>
References: <1361772305-1665-1-git-send-email-pshelar@nicira.com>
	<504C9EFCA2D0054393414C9CB605C37F1C01B740@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757981Ab3BYUsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:48:19 -0500
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1C01B740@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 25 Feb 2013 11:40:06 +0000

>> -----Original Message-----
>> From: Pravin B Shelar [mailto:pshelar@nicira.com]
>> Sent: Monday, February 25, 2013 8:05 AM
>> To: davem@davemloft.net
>> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Pravin B Shelar
>> Subject: [PATCH net-next 1/2] IP_GRE: Fix GRE_CSUM case.
>> 
>> commit "ip_gre: allow CSUM capable devices to handle packets"
>> aa0e51cdda005cd37e2, broke GRE_CSUM case.
>> GRE_CSUM needs checksum computed for inner packet. Therefore
>> csum-calculation can not be offloaded if tunnel device requires
>> GRE_CSUM.  Following patch fixes it by computing inner packet checksum
>> for GRE_CSUM type, for all other type of GRE devices csum is offloaded.
>> 
>> CC: Dmitry Kravkov <dmitry@broadcom.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
 ...
> Tested the series on two different devices
> 
> Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
> 
> 

Applied.
