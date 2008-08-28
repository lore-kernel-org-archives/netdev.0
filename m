From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] sky2: EEPROM read/write bug fixes
Date: Thu, 28 Aug 2008 12:13:25 +0100
Message-ID: <20080828111323.GI7908@solarflare.com>
References: <20080827204626.4b65862f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:55938 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746AbYH1LNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 07:13:36 -0400
Content-Disposition: inline
In-Reply-To: <20080827204626.4b65862f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Cleanup and harden the routines accessing the EEPROM.
>   1. Prevent spin forever waiting for the TWSI bus
>   2. Fix write eeprom to write full words rather than only 16 bits 
>     Luckly the vendor doesn't provide EEPROM in Linux format so it must never
>     have been used.
>   3. Don't allow partial eeprom writes, not needed, not safe.
[...]

You should be able to replace the VPD access code with calls through
pci_dev->vpd->ops - though you'd need to remove some declarations from
drivers/pci/pci.h to include/linux/pci.h.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
