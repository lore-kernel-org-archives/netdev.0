From: Adam Ford <aford173@gmail.com>
Subject: Fwd: DA850-evm MAC Address is random
Date: Mon, 28 Aug 2017 10:32:17 -0500
Message-ID: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34178 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdH1PcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 11:32:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The davinvi_emac MAC address seems to attempt a call to
ti_cm_get_macid in cpsw-common.c but it returns the message
'davinci_emac davinci_emac.1: incompatible machine/device type for
reading mac address ' and then generates a random MAC address.

The function appears to lookup varions boards using
'of_machine_is_compaible' and supports dm8148, am33xx, am3517, dm816,
am4372 and dra7.  I don't see the ti,davinci-dm6467-emac which is
what's shown in the da850 device tree.

Is there a patch somewhere for supporting the da850-evm?

If not, is there a way to pass the MAC address from U-Boot to the
driver so it doesn't generate a random MAC?

adam
