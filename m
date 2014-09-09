From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 5/8] net: pxa168_eth: get and set the mac address on the Ethernet controller
Date: Tue, 09 Sep 2014 17:59:59 +0200
Message-ID: <3876979.iyRVchmjb7@wuerfel>
References: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com> <1410273848-24663-6-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
	jszhang@marvell.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:60400 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756746AbaIIQAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 12:00:09 -0400
In-Reply-To: <1410273848-24663-6-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 September 2014 16:44:05 Antoine Tenart wrote:
> When changing the MAC address, in addition to updating the dev_addr in
> the net_device structure, this patch also update the MAC address
> registers (high and low) of the Ethernet controller with the new MAC.
> The address stored in these registers is used for IEEE 802.3x Ethernet
> flow control, which is already enabled.
> 
> This patch also tries reading the MAC address stored in these registers
> when probing the driver, to use the MAC address set by the bootloader
> and avoid using a random one.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> 

I think it would be good to allow overriding the address using a
'mac-address' property from DT. It's very easy to call
of_get_mac_address().

	Arnd
