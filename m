From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Fix integration of eee-broken-modes
Date: Tue, 20 Dec 2016 13:51:20 -0500 (EST)
Message-ID: <20161220.135120.552249230607699619.davem@davemloft.net>
References: <1482159938-13239-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, carlo@caione.org, khilman@baylibre.com,
        martin.blumenstingl@googlemail.com, neolynx@gmail.com,
        andrew@lunn.ch, narmstrong@baylibre.com,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        julia.lawall@lip6.fr, yegorslists@googlemail.com, afaerber@suse.de
To: jbrunet@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765809AbcLTSvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 13:51:33 -0500
In-Reply-To: <1482159938-13239-1-git-send-email-jbrunet@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerome Brunet <jbrunet@baylibre.com>
Date: Mon, 19 Dec 2016 16:05:35 +0100

> The purpose of this series is to fix the integration of the ethernet phy
> property "eee-broken-modes" [0]
> 
> The v3 of this series has been merged, missing a fix (error reported by
> kbuild robot) available in the v4 [1]
> 
> More importantly, Florian opposed adding a DT property mapping a device
> register this directly [2]. The concern was that the property could be
> abused to implement platform configuration policy. After discussing it,
> I think we agreed that such information about the HW (defect) should appear
> in the platform DT. However, the preferred way is to add a boolean property
> for each EEE broken mode.
> 
> [0]: http://lkml.kernel.org/r/1480326409-25419-1-git-send-email-jbrunet@baylibre.com
> [1]: http://lkml.kernel.org/r/1480348229-25672-1-git-send-email-jbrunet@baylibre.com
> [2]: http://lkml.kernel.org/r/e14a3b0c-dc34-be14-48b3-518a0ad0c080@gmail.com

Series applied, thank you.
