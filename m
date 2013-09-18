From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [RFC] b44: use phylib
Date: Wed, 18 Sep 2013 17:03:47 +0200
Message-ID: <5239C0D3.2080008@hauke-m.de>
References: <1377298608-18016-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:46503 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab3IRPD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 11:03:59 -0400
In-Reply-To: <1377298608-18016-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2013 12:56 AM, Hauke Mehrtens wrote:
> This splits the driver into the mac and a phy driver. On routers where
> this driver is used we have a switch which implements a phy and can be
> controlled by a phy driver.
> 
> I have just tested this on my router with a switch as phy and not on normal desktop PC.
> 
> This is based on a patch by Florian Fainelli <florian@openwrt.org>

Hi Gary Zambrano,

Could you please test this patch or could someone else please test this
patch with a b44 chip in a desktop or laptop. I have just tested this
patch on some routers where a BCM53XX switch is used as PHY, but do not
own a device where b44 is used as a normal NIC.

Hauke
