From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Mellanox ethernet card failed when probing
Date: Fri, 3 Feb 2012 16:13:27 +0100
Message-ID: <CAL8zT=gV=pe4Bnn188ngnPk8s=7JSGARY0g6uVHASVrUXNKeKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jean-Michel Hautbois <jhautbois@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41322 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab2BCPN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:13:28 -0500
Received: by werb13 with SMTP id b13so2768825wer.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 07:13:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am using a HP server with Mellanox ethernet cards in it.
I have compiled the latest linux 3.2 version, and I am encountering
the following error :

[ 1094.644193] mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2011)
[ 1094.644196] mlx4_core: Initializing 0000:06:00.0
[ 1097.183671] mlx4_core 0000:06:00.0: irq 84 for MSI/MSI-X
[ 1097.183681] mlx4_core 0000:06:00.0: irq 85 for MSI/MSI-X
[ 1097.183690] mlx4_core 0000:06:00.0: irq 86 for MSI/MSI-X
[ 1097.183697] mlx4_core 0000:06:00.0: irq 87 for MSI/MSI-X
[ 1097.201267] mlx4_core: Initializing 0000:06:00.1
[ 1097.201509] mlx4_core 0000:06:00.1: Multiple PFs not yet supported.
Skipping PF.
[ 1097.201844] mlx4_core: probe of 0000:06:00.1 failed with error -22
[ 1097.201853] mlx4_core: Initializing 0000:06:00.2
[ 1097.202078] mlx4_core 0000:06:00.2: Multiple PFs not yet supported.
Skipping PF.
[ 1097.202237] mlx4_core: probe of 0000:06:00.2 failed with error -22
[ 1097.202246] mlx4_core: Initializing 0000:06:00.3
[ 1097.202460] mlx4_core 0000:06:00.3: Multiple PFs not yet supported.
Skipping PF.
[ 1097.202911] mlx4_core: probe of 0000:06:00.3 failed with error -22
[ 1097.202919] mlx4_core: Initializing 0000:06:00.4
[ 1097.203143] mlx4_core 0000:06:00.4: Multiple PFs not yet supported.
Skipping PF.
[ 1097.203301] mlx4_core: probe of 0000:06:00.4 failed with error -22
[ 1097.203308] mlx4_core: Initializing 0000:06:00.5
[ 1097.203521] mlx4_core 0000:06:00.5: Multiple PFs not yet supported.
Skipping PF.
[ 1097.203937] mlx4_core: probe of 0000:06:00.5 failed with error -22
[ 1097.203945] mlx4_core: Initializing 0000:06:00.6
[ 1097.204167] mlx4_core 0000:06:00.6: Multiple PFs not yet supported.
Skipping PF.
[ 1097.204322] mlx4_core: probe of 0000:06:00.6 failed with error -22
[ 1097.204328] mlx4_core: Initializing 0000:06:00.7
[ 1097.204541] mlx4_core 0000:06:00.7: Multiple PFs not yet supported.
Skipping PF.
[ 1097.209445] mlx4_core: probe of 0000:06:00.7 failed with error -22
[ 1097.239493] mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.0 (Dec 2011)
[ 1097.239682] mlx4_en 0000:06:00.0: Activating port:1
[ 1097.241144] mlx4_en: eth8: Using 8 TX rings
[ 1097.241147] mlx4_en: eth8: Using 4 RX rings
[ 1097.241285] mlx4_en: eth8: Initializing port
[ 1097.241355] mlx4_en 0000:06:00.0: Activating port:2
[ 1097.244236] mlx4_en: eth9: Using 8 TX rings
[ 1097.244239] mlx4_en: eth9: Using 4 RX rings
[ 1097.244316] mlx4_en: eth9: Initializing port
[ 1097.544700] mlx4_en: eth8: Link Up
[ 1097.798226] mlx4_en: eth9_rename: Link Up

I think this is firmware related, but I don't know for sure.
I can't find any firmware generated in the /lib/firmware directory...

Thanks in advance for your help.
Regards,
JM
