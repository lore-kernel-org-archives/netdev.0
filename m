From: Sriram V <vshrirama@gmail.com>
Subject: Autoneg off in TI cpsw driver
Date: Fri, 17 Feb 2017 00:01:32 +0530
Message-ID: <CAH9_wRMwiZA6GxdwMbOZjs-t-hnMaCRB1RSQ6nGoLOUJ+PxzRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mugunthanvnm@ti.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33723 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932302AbdBPSbd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 13:31:33 -0500
Received: by mail-vk0-f46.google.com with SMTP id k127so15749832vke.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 10:31:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am using a Linux Kernel 4.1 Kernel. on AM437X with dual emac configuration.

What i find is if i do the following the Link does not come up.

1. run ethtool -s eth1 speed 10 duplex full autoneg off
2. remove cable
3. plug it in.

With the above sequence. The link does not come up. the plug in is not detected

Am i missing something or is this the default behaviour.

Regards,
Sriram
