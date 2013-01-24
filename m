From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH 0/3] tg3: add support for Ethernet core in BCM4785
Date: Thu, 24 Jan 2013 18:21:09 +0100
Message-ID: <51016D85.8030705@hauke-m.de>
References: <1358020905-9924-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	m@bues.ch
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:56710 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab3AXRVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 12:21:19 -0500
In-Reply-To: <1358020905-9924-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2013 09:01 PM, Hauke Mehrtens wrote:
> These patches are adding support for the Ethernet core found in the BCM4705/BCM4785 SoC.
> 
> Hauke Mehrtens (3):
>   ssb: add missing method ssb_gige_get_macaddr
>   tg3: make it possible to provide phy_id in ioctl
>   tg3: add support for Ethernet core in bcm4785
> 
>  drivers/net/ethernet/broadcom/tg3.c |  137 +++++++++++++++++++++++++++++++----
>  drivers/net/ethernet/broadcom/tg3.h |    5 ++
>  include/linux/pci_ids.h             |    1 +
>  include/linux/ssb/ssb_driver_gige.h |    3 +
>  4 files changed, 133 insertions(+), 13 deletions(-)
> 
Hi David,

Should I resend these patches with error handling if the mac address
could not be set?

Hauke
