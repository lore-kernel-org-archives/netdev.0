From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net v2 0/4] be2net fixes
Date: Mon, 3 Mar 2014 09:06:45 +0000
Message-ID: <7F44EA5110810A40B7DAFB605C41975D302BB768@CMEXMB1.ad.emulex.com>
References: <1393836845-27795-1-git-send-email-somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:39858 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbaCCJGr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 04:06:47 -0500
In-Reply-To: <1393836845-27795-1-git-send-email-somnath.kotur@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will send the `tx_compl` timeout patch ([PATCH net 4/5] be2net: wait longer to reap TX compls in be_close())
 that was part of the V1 patch set later as it is still being worked out....

Thanks
Som

> -----Original Message-----
> From: Somnath Kotur
> Sent: Monday, March 03, 2014 2:24 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Somnath Kotur
> Subject: [PATCH net v2 0/4] be2net fixes
> 
> Please apply.
> 
> Somnath Kotur (1):
>   be2net: Fix to reset transparent vlan tagging
> 
> Somnath kotur (1):
>   be2net: clear promiscuous bits in adapter->flags while disabling
>     promiscuous mode
> 
> Vasundhara Volam (2):
>   be2net: Fix skb double free in be_xmit_wrokarounds() failure path
>   be2net: isolate TX workarounds not applicable to Skyhawk-R
> 
>  drivers/net/ethernet/emulex/benet/be.h      |    4 +-
>  drivers/net/ethernet/emulex/benet/be_main.c |   84 +++++++++++++++---
> ---------
>  2 files changed, 50 insertions(+), 38 deletions(-)
