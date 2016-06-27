From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: Supporting C45 PHY without ID registers
Date: Mon, 27 Jun 2016 16:36:20 -0700
Message-ID: <CAAtXAHdfL07C+p-FcafHL5s0Noqh4Br1VP6dcyBr89wWidvsJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:36161 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbcF0XgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 19:36:21 -0400
Received: by mail-vk0-f48.google.com with SMTP id u64so208352vkf.3
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 16:36:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have a 10GigE PHY that I'm working with that has most of it's
functionality availabile via MDIO
in a clause 45 compliant fashion, however the usual probe method fails
since the id registers
are not implemented.

I hacked up drivers/of/of_mdio.c to include something similar to of_get_phy_id()
for c45 phys but I was wondering if someone else has a better idea
than this in my dt:

ethernet_phy1: ethernet-phy@4 {
    compatible = "ethernet-phy-id0000.0000",
                        "ethernet-phy-id4242.4242",
                        "ethernet-phy-id0000.0000",
                        "ethernet-phy-id4343.4343",
                        "ethernet-phy-ieee802.3-c45";
    reg = <4>;
};

Where I made up 42424242 and 43434343 as ids for my PCS / PMA. Ideas?

Cheers,

Moritz
