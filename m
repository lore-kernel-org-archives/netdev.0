From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 4/6] net: ethernet: bgmac: convert to feature flags
Date: Fri, 8 Jul 2016 11:11:39 -0700
Message-ID: <577FECDB.5010608@gmail.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
 <1467932938-21819-5-git-send-email-jon.mason@broadcom.com>
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
In-Reply-To: <1467932938-21819-5-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/07/2016 04:08 PM, Jon Mason wrote:
> The bgmac driver is using the bcma provides device ID and revision, as
> well as the SoC ID and package, to determine which features are
> necessary to enable, reset, etc in the driver.   In anticipation of
> removing the bcma requirement for this driver, these must be changed to
> not reference that struct.  In place of that, each "feature" has been
> given a flag, and the flags are enabled for their respective device and
> SoC.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
