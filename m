From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dt: bindings: Add a generic ethernet device binding
Date: Thu, 14 Jul 2016 16:17:07 -0700 (PDT)
Message-ID: <20160714.161707.2089949241813985527.davem@davemloft.net>
References: <1468405204-5845-1-git-send-email-hdegoede@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
	maxime.ripard@free-electrons.com, wens@csie.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
To: hdegoede@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbcGNXRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 19:17:13 -0400
In-Reply-To: <1468405204-5845-1-git-send-email-hdegoede@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans de Goede <hdegoede@redhat.com>
Date: Wed, 13 Jul 2016 12:20:04 +0200

> On some boards (android tablets) different batches use different sdio
> wifi modules. This is not a problem since sdio is a discoverable bus,
> so we only need to describe and activate the mmc controller in dt and
> then the kernel will automatically load the right driver.
> 
> But sometimes it is useful to specify certain ethernet properties for
> these "unknown" sdio devices, specifically we want the boot-loader
> to be able to set "local-mac-address" as some of these sdio wifi
> modules come without an eeprom / without a factory programmed mac
> address.
> 
> Since the exact device is unknown (differs per batch) we cannot use
> a wifi-chip specific compatible. This commit adds a new
> "generic,ethernet" binding for use in dt-nodes describing such an
> unknown ethernet device.
> 
> Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
> Signed-off-by: Hans de Goede <hdegoede@redhat.com>

Precedence exists for a "system ethernet address" as far back as the
original sparc device tree implementation, so please just specify it
that way rather than trying to force having to make an alias or
reference to it from a specific device.
