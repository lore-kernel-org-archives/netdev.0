From: Florian Fainelli <florian.fainelli@broadcom.com>
Subject: Re: [PATCH v2 3/6] net: ethernet: bgmac: move BCMA MDIO Phy code into
 a separate file
Date: Fri, 8 Jul 2016 11:11:23 -0700
Message-ID: <577FECCB.9050007@broadcom.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
 <1467932938-21819-4-git-send-email-jon.mason@broadcom.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33286 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755972AbcGHSLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 14:11:32 -0400
Received: by mail-pf0-f178.google.com with SMTP id i123so14780764pfg.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 11:11:27 -0700 (PDT)
In-Reply-To: <1467932938-21819-4-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2016 04:08 PM, Jon Mason wrote:
> Move the BCMA MDIO phy into a separate file, as it is very tightly
> coupled with the BCMA bus.  This will help with the upcoming BCMA
> removal from the bgmac driver.  Optimally, this should be moved into
> phy drivers, but it is too tightly coupled with the bgmac driver to
> effectively move it without more changes to the driver.
> 
> Note: the phy_reset was intentionally removed, as the mdio phy subsystem
> automatically resets the phy if a reset function pointer is present.  In
> addition to the moving of the driver, this reset function is added.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
