From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: ni52.c warnings explosion
Date: Wed, 20 Feb 2008 23:26:24 -0800
Message-ID: <1203578784.20345.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:30126 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbYBUH0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 02:26:10 -0500
Received: by wa-out-1112.google.com with SMTP id v27so4373995wah.23
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 23:26:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Somewhere between 2.6.25-rc1 and -rc2 something changed that produces a
few hundred sparse warnings in ni52.c.

I see Alan touched it last.

drivers/net/ni52.c:219:15: warning: incorrect type in argument 1 (different address spaces)
drivers/net/ni52.c:219:15:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/ni52.c:219:15:    got unsigned char *<noident>

If you want the full log, let me know.

Harvey


