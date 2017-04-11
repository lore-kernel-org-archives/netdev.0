From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Tue, 11 Apr 2017 13:59:08 -0700
Message-ID: <edc488b1-8ea1-fc69-0700-68ffaf8f6742@gmail.com>
References: <20170411205237.29309-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35986 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753618AbdDKU7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 16:59:10 -0400
In-Reply-To: <20170411205237.29309-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2017 01:52 PM, Vivien Didelot wrote:
> This patch moves as is the legacy DSA code from dsa.c to legacy.c,
> except the few shared symbols which remain in dsa.c.
> 
> Compile legacy.o only if a new CONFIG_NET_DSA_LEGACY symbol is enabled,
> which is true by default.
> 
> DSA drivers without legacy support don't need the probe function as well
> as driver registration helpers anymore, so remove their definitions if
> CONFIG_NET_DSA_LEGACY is disabled.
> 
> NET_DSA_MV88E6060 and NET_DSA_BCM_SF2 now depend on the legacy support.

BCM_SF2 is not dependent on legacy support since it got converted to the
new API in the past few months.

You may want to generate your patch with git format-patch -M to help
detect renames/code movements.

Thanks for doing this!
-- 
Florian
