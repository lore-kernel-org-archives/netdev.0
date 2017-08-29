From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] Endian fixes for SYSTEMPORT/SF2/MDIO
Date: Tue, 29 Aug 2017 13:17:57 -0700
Message-ID: <6ca07a0f-d4d0-74a3-f0bf-862b80ee87ef@gmail.com>
References: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35638 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdH2USD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:18:03 -0400
Received: by mail-wm0-f65.google.com with SMTP id e204so2134694wma.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:18:03 -0700 (PDT)
In-Reply-To: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2017 11:39 AM, Florian Fainelli wrote:
> Hi David,
> 
> While trying an ARM BE kernel for kinks, the 3 drivers below started not
> working and the reasons why became pretty obvious because the register space
> remains LE (hardwired), except for Broadcom MIPS where it follows the CPU's
> native endian (let's call that a feature).

David, I found a minor problem in the RSB endian configuration for
SYSTEMPOR Lite that uses two bits for that, I will repost shortly.

> 
> Thanks!
> 
> Florian Fainelli (4):
>   net: systemport: Use correct I/O accessors
>   net: dsa: bcm_sf2: Use correct I/O accessors
>   net: systemport: Set correct RSB endian bits based on host
>   net: phy: mdio-bcm-unimac: Use correct I/O accessors
> 
>  drivers/net/dsa/bcm_sf2.h                  | 12 +++++------
>  drivers/net/ethernet/broadcom/bcmsysport.c | 21 ++++++++++++--------
>  drivers/net/phy/mdio-bcm-unimac.c          | 32 ++++++++++++++++++++++++------
>  3 files changed, 45 insertions(+), 20 deletions(-)
> 


-- 
Florian
