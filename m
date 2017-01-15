From: Joe Perches <joe@perches.com>
Subject: Re: net: stmmac: don't use netdev_[dbg, info, ..] before net_device
 is registered
Date: Sun, 15 Jan 2017 10:23:40 -0800
Message-ID: <1484504620.14692.8.camel@perches.com>
References: <da21972e-87cd-370c-e9ff-219fc82ebd10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <hkallweit1@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0077.hostedemail.com ([216.40.44.77]:53996 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751174AbdAOSXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 13:23:43 -0500
In-Reply-To: <da21972e-87cd-370c-e9ff-219fc82ebd10@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-01-15 at 19:17 +0100, Heiner Kallweit wrote:
> Don't use netdev_info and friends before the net_device is registered.
> This avoids ugly messages like
> "meson8b-dwmac c9410000.ethernet (unnamed net_device) (uninitialized):
> Enable RX Mitigation via HW Watchdog Timer"

It'd be nice to mention the new message prefix.
