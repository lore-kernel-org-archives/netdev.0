From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 00/12] net: dsa: b53/bcm_sf2 cleanups
Date: Mon, 18 Sep 2017 14:46:48 -0700
Message-ID: <24876029-5ebb-075e-3f02-50cf0856474f@gmail.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36086 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750990AbdIRVqz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:46:55 -0400
Received: by mail-wr0-f196.google.com with SMTP id g50so1141636wra.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:46:54 -0700 (PDT)
In-Reply-To: <20170918214128.27896-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2017 02:41 PM, Florian Fainelli wrote:
> Hi all,
> 
> This patch series is a first pass set of clean-ups to reduce the number of LOCs
> between b53 and bcm_sf2 and sharing as many functions as possible.
> 
> There is a number of additional cleanups queued up locally that require more
> thorough testing.

David, I just spotted a missing EXPORT_SYMBOL() in patch 8 that was not
flagged since I had temporarily disabled modular build, I will resubmit
this shortly after checking the other patches too. Thanks!

> 
> Thanks!
> 
> Florian Fainelli (12):
>   net: dsa: b53: Remove is_cpu_port()
>   net: dsa: b53: Make b53_enable_cpu_port() take a port argument
>   net: dsa: b53: Defer port enabling to calling port_enable
>   net: dsa: bcm_sf2: Defer port enabling to calling port_enable
>   net: dsa: b53: Use a macro to define I/O operations
>   net: dsa: b53: Move Broadcom header setup to b53
>   net: dsa: b53: Define EEE register page
>   net: dsa: b53: Move EEE functions to b53
>   net: dsa: b53: Wire-up EEE
>   net: dsa: b53: Export b53_imp_vlan_setup()
>   net: dsa: bcm_sf2: Use SF2_NUM_EGRESS_QUEUES for CFP
>   net: dsa: bcm_sf2: Utilize b53_{enable,disable}_port
> 
>  drivers/net/dsa/b53/b53_common.c | 150 ++++++++++++++++++++++++++++++++----
>  drivers/net/dsa/b53/b53_priv.h   | 145 ++++++++---------------------------
>  drivers/net/dsa/b53/b53_regs.h   |  48 ++++++++++++
>  drivers/net/dsa/bcm_sf2.c        | 161 +++------------------------------------
>  drivers/net/dsa/bcm_sf2.h        |   2 -
>  drivers/net/dsa/bcm_sf2_cfp.c    |   6 +-
>  drivers/net/dsa/bcm_sf2_regs.h   |  11 ---
>  7 files changed, 227 insertions(+), 296 deletions(-)
> 


-- 
Florian
