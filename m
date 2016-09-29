From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] [v2] Add basic ACPI support to the Qualcomm
 Technologies EMAC driver
Date: Thu, 29 Sep 2016 01:50:38 -0400 (EDT)
Message-ID: <20160929.015038.2293483616753188761.davem@davemloft.net>
References: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linaro-acpi@lists.linaro.org,
        linux-arm-kernel@lists.infradead.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbcI2Fus (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:50:48 -0400
In-Reply-To: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 28 Sep 2016 11:58:41 -0500

> This patch series adds support to the EMAC driver for extracting addresses,
> interrupts, and some _DSDs (properties) from ACPI.  The first two patches
> clean up the code, and the third patch adds ACPI-specific functionality.
> 
> The first patch fixes a bug with handling the platform_device for the
> internal PHY.  This phy is treated as a separate device in both DT and
> ACPI, but since the platform is not released automatically when the 
> driver unloads, managed functions like devm_ioremap_resource cannot be
> used. 
> 
> The second patch replaces of_get_mac_address with its platform-independent
> equivalent device_get_mac_address.  
> 
> The third patch parses the ACPI tables to obtain the platform_device for
> the primary EMAC node ("QCOM8070") and the internal phy node ("QCOM8071").

Series applied, thanks.
