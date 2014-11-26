From: Rajib Karmakar <rajibkit@gmail.com>
Subject: Multiple DSA switch on shared MII
Date: Wed, 26 Nov 2014 10:22:57 +0530
Message-ID: <CAOi_9k8NwpVFxg=9VOagVt3m6hn2uLKuCZ_0-+4PciJNRWuTmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:61011 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbaKZEw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 23:52:58 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so2056120pac.22
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 20:52:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am developing a DSA driver for Marvell 6172 and need to create 2 dsa
switch chip (one for WAN and one for LAN).

My device has 2 MACs and one shared mii_bus. I have added two
dsa_platform_data structures and registered them but cannot probe as
dsa_probe tries mdio_register() on the same bus and fails.

Is it possible to create two DSA switch on same (shared) mii?

Regards,
Rajib
