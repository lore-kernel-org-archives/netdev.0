From: Kevin Wilson <wkevils@gmail.com>
Subject: wanted_features in cxgb3 driver
Date: Sun, 11 Nov 2012 11:14:57 +0200
Message-ID: <CAGXs5wXxmRjVDKtiJgjzkrtEGvpxcSNr7sTF8xoL+p2yL0taEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:52324 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423Ab2KKJO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 04:14:59 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so3900065lag.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 01:14:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
A question:
I saw two assignment to dev->wanted_features in cxgb_extension_ioctl() in
drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c.

This is the only driver which sets wanted_features of netdevice (in
net-next tree).

Is there some special reason for that ?  or is it some legacy matter ?


According to Documentation/networking/netdev-features.txt,
....
netdev->wanted_features set contains feature set requested by user.
...    This set is internal to networking core and should not be
referenced in drivers.
...

rgs,
Kevin
