From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Endian fixes for SYSTEMPORT/SF2/MDIO
Date: Tue, 29 Aug 2017 14:42:54 -0700 (PDT)
Message-ID: <20170829.144254.740239595444825239.davem@davemloft.net>
References: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdH2Vm5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 17:42:57 -0400
In-Reply-To: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 29 Aug 2017 11:39:41 -0700

> While trying an ARM BE kernel for kinks, the 3 drivers below started not
> working and the reasons why became pretty obvious because the register space
> remains LE (hardwired), except for Broadcom MIPS where it follows the CPU's
> native endian (let's call that a feature).

Series applied, thanks Florian.
