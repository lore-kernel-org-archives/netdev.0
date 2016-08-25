From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: bcm_sf2: Utilize mask clear/set helpers in
 bcm_sf2_intr_disable
Date: Thu, 25 Aug 2016 15:23:07 -0700
Message-ID: <e25b5547-8f7e-f176-5533-e6a18f543832@gmail.com>
References: <1472163645-7058-1-git-send-email-fainelli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <florian.fainelli@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33287 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755128AbcHYWXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 18:23:46 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so3702198pac.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 15:23:09 -0700 (PDT)
In-Reply-To: <1472163645-7058-1-git-send-email-fainelli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2016 03:20 PM, Florian Fainelli wrote:
> From: Florian Fainelli <florian.fainelli@broadcom.com>
> 
> And while at it, remove the unecessary writing of zeroes to the CPU_MASK_CLEAR
> register since it has no functional use.
> 
> refs #SWLINUX-4144
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@broadcom.com>

I will resend that, this taken from an internal tree as-is, sorry about
that.
-- 
Florian
