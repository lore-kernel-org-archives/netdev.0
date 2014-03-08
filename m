From: Andy Lutomirski <luto@amacapital.net>
Subject: sfc 0000:05:00.0 eth4: pci_enable_pcie_error_reporting failed (-5)
Date: Sat, 8 Mar 2014 10:17:33 -0800
Message-ID: <CALCETrX0tn7WjTqnuQ5v+ZUJoJO2bbSb-ykzX5A3yssXKys8fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Network Development <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:61636 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaCHSRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 13:17:54 -0500
Received: by mail-vc0-f176.google.com with SMTP id lc6so4997148vcb.35
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 10:17:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this is because my machine sets the FIRMWARE_FIRST flag.
Should this message be downgraded to KERN_INFO or even KERN_DEBUG?

--Andy
