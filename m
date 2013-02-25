From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] Revert "ip_gre: propogate target device
 GSO capability to the tunnel device"
Date: Mon, 25 Feb 2013 15:48:30 -0500 (EST)
Message-ID: <20130225.154830.2039505864744729373.davem@davemloft.net>
References: <1361772312-1698-1-git-send-email-pshelar@nicira.com>
	<504C9EFCA2D0054393414C9CB605C37F1C01B72C@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758022Ab3BYUsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:48:32 -0500
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1C01B72C@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 25 Feb 2013 11:38:36 +0000

>> -----Original Message-----
>> From: Pravin B Shelar [mailto:pshelar@nicira.com]
>> Sent: Monday, February 25, 2013 8:05 AM
>> To: davem@davemloft.net
>> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Pravin B Shelar
>> Subject: [PATCH net-next 2/2] Revert "ip_gre: propogate target device GSO capability to the tunnel device"
>> 
>> This reverts commit eb6b9a8cad65e820b145547844b108117cece3a0.
>> 
>> Above commit limits GSO capability of gre device to just TSO, but
>> software GRE-GSO is capable of handling all GSO capabilities.
>> 
>> This patch also fixes following panic which reverted commit introduced:-
 ...
>> CC: Dmitry Kravkov <dmitry@broadcom.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
 ...
> Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
> 

Applied.
