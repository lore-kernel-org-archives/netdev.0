From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/4] ARM: dts: Enable emac node on the rk3188-radxarock boards
Date: Wed, 03 Sep 2014 19:45:50 +0200
Message-ID: <2909336.qILuPbXDGe@wuerfel>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com> <CAFnsNoSmHwN3nJ5ZJL5fc_-kaECCoLBvpdBYQxkyLcUzLx5MTw@mail.gmail.com> <CABgxDoJOJ9bM2CgXyXjPvsv2DN_QO+HPAzCwfjdyKFDpUAOtOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: PERIER Romain <romain.perier@gmail.com>,
	Naoki FUKAUMI <naobsd@gmail.com>,
	devicetree <devicetree@vger.kernel.org>,
	Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>,
	netdev <netdev@vger.kernel.org>,
	linux-rockchip@lists.infradead.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:50259 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaICRp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 13:45:59 -0400
In-Reply-To: <CABgxDoJOJ9bM2CgXyXjPvsv2DN_QO+HPAzCwfjdyKFDpUAOtOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 September 2014 18:37:16 PERIER Romain wrote:
> It is an optional property used by arc-emac (the core driver), if it
> is not present the core driver generates one for you.
> Problem being that with this property two radxa rock boards connected
> on the same local network might have the same mac address.
> 
> In this case it would be probably better to remove this property. What
> do you think ?
> 

It would typically be filled in by the boot loader, and be all-zeroes
in the kernel-supplied dts file. I don't see a point in hardcoding
a particular MAC address in the dts file, since that won't work
unless it's the only device of that type in the network segment.

	Arnd
