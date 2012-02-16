From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: net: Regression in tg3 driver
Date: Wed, 15 Feb 2012 19:01:28 -0800
Message-ID: <CAGK4HS_wT+6mwH6xdji3c-H3w5vOWpgL=_fq=eFLDamybxzB-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>, mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:57503 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab2BPDBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 22:01:30 -0500
Received: by vbjk17 with SMTP id k17so1198271vbj.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 19:01:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My Ethernet card stopped working after I pulled to the latest net-next
kernel. lspci shows the Broadcom cards and so does ifconfig but
dhclient does not work on the cards. Also, the lights on the card never come on.

lspci output
02:03.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704
Gigabit Ethernet (rev 10)
02:03.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704
Gigabit Ethernet (rev 10)

# lsmod | grep tg3
tg3                   129451  0

The following commit may be the cause:
e740522e6d3a6c3014da30f65fe254bc7f6410d7 (tg3: Use *_UNKNOWN ethtool
definitions)

It seems to be the first commit that causes this.

I am not running ethtool though AFAIK. Please let me know if you need
any other information help in debugging.

Thanks,
Vijay Subramanian
