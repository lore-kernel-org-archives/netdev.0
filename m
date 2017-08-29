From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] Endian fixes for SYSTEMPORT/SF2/MDIO
Date: Tue, 29 Aug 2017 14:45:30 -0700
Message-ID: <d8ae99de-398d-f314-309f-50c36df9240a@gmail.com>
References: <1504031985-52808-1-git-send-email-f.fainelli@gmail.com>
 <20170829.144254.740239595444825239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:38480 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbdH2Vpf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 17:45:35 -0400
Received: by mail-qt0-f180.google.com with SMTP id w42so20431247qtg.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 14:45:35 -0700 (PDT)
In-Reply-To: <20170829.144254.740239595444825239.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2017 02:42 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 29 Aug 2017 11:39:41 -0700
> 
>> While trying an ARM BE kernel for kinks, the 3 drivers below started not
>> working and the reasons why became pretty obvious because the register space
>> remains LE (hardwired), except for Broadcom MIPS where it follows the CPU's
>> native endian (let's call that a feature).
> 
> Series applied, thanks Florian.

If you have not pushed yet, seems like not, can you check you applied v2
of this patch series, in particular this patch:

http://patchwork.ozlabs.org/patch/807296/

Thanks!
-- 
Florian
