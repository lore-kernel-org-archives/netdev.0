From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 5/6] net: ethernet: bgmac: Add platform device support
Date: Fri, 8 Jul 2016 11:11:57 -0700
Message-ID: <577FECED.6060906@gmail.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
 <1467932938-21819-6-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, hauke@hauke-m.de,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>, davem@davemloft.net,
	f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467932938-21819-6-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/07/2016 04:08 PM, Jon Mason wrote:
> The bcma portion of the driver has been split off into a bcma specific
> driver.  This has been mirrored for the platform driver.  The last
> references to the bcma core struct have been changed into a generic
> function call.  These function calls are wrappers to either the original
> bcma code or new platform functions that access the same areas via MMIO.
> This necessitated adding function pointers for both platform and bcma to
> hide which backend is being used from the generic bgmac code.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
