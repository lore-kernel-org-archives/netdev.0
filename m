From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu, 15 Jan 2015 13:34:48 +0100
Message-ID: <2318041.V2OJAPu7gC@wuerfel>
References: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org> <5550127.3sXOcCISZN@wuerfel> <bca0eaf2183036ff6a913daea6e09ad9.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: jcliburn@gmail.com, grant.likely@linaro.org, robh+dt@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: wstephen@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bca0eaf2183036ff6a913daea6e09ad9.squirrel@www.codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 January 2015 08:12:51 wstephen@codeaurora.org wrote:
> 
> The nss-gmac driver is for the internal GMAC IP in the Qualcomm IPQ806x
> SoC. There are 2 ARM cores and 2 NSS cores inside the IPQ806x SoC. The
> main purpose of these NSS cores is to offload the networking stack from
> the ARM cores to achieve high performance at routing/ipsec..etc without
> exhausting the ARM core CPU cycles. There is another nss-drv driver for
> the NSS cores.

I see.

> The nss-gmac driver is designed to work standalone or with the nss-drv
> driver so the switchable data plane overlay was implemented. When it
> worked standalone, the data plane is running on the ARM core as a standard
> networking driver.

How do you decide which way it gets used on a particular system?

> The nss-drv driver can take over the data plane and
> offload it to the NSS cores. The STMicro stmmac driver does not have this
> kind of overlay design so is not suitable for IPQ806x. This is why we
> don't based on the stmmac driver

Which kind of offload is implemented specifically? 'data plane' sounds
fairly generic and could mean anything, and the code isn't readable enough
in its current form for me to find out.

	Arnd
