From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: Re: net: stmmac: don't use netdev_[dbg, info, ..] before net_device
 is registered
Date: Sun, 15 Jan 2017 19:28:54 +0100
Message-ID: <555858b8-3655-1b21-85c3-35cad5dbc2a4@gmail.com>
References: <da21972e-87cd-370c-e9ff-219fc82ebd10@gmail.com>
 <1484504620.14692.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35499 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751174AbdAOS3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 13:29:00 -0500
Received: by mail-lf0-f41.google.com with SMTP id m78so68149653lfg.2
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 10:28:59 -0800 (PST)
In-Reply-To: <1484504620.14692.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.01.2017 um 19:23 schrieb Joe Perches:
> On Sun, 2017-01-15 at 19:17 +0100, Heiner Kallweit wrote:
>> Don't use netdev_info and friends before the net_device is registered.
>> This avoids ugly messages like
>> "meson8b-dwmac c9410000.ethernet (unnamed net_device) (uninitialized):
>> Enable RX Mitigation via HW Watchdog Timer"
> 
> It'd be nice to mention the new message prefix.
> 
Sorry, I thought it's obvious because here the message trail looks
like this:

meson8b-dwmac c9410000.ethernet: DMA HW capability register supported
meson8b-dwmac c9410000.ethernet: Normal descriptors
meson8b-dwmac c9410000.ethernet: RX Checksum Offload Engine supported
meson8b-dwmac c9410000.ethernet: COE Type 2
meson8b-dwmac c9410000.ethernet: TX Checksum insertion supported
meson8b-dwmac c9410000.ethernet: Wake-Up On Lan supported
meson8b-dwmac c9410000.ethernet (unnamed net_device) (uninitialized): Enable RX Mitigation via HW Watchdog Timer

Better update the commit message and send a v2?
