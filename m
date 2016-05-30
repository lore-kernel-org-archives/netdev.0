From: David Binderman <linuxdev.baldrick@gmail.com>
Subject: linux-4.7-rc1/drivers/isdn/capi/capidrv.c:1707]: (style) Redundant condition
Date: Mon, 30 May 2016 08:52:32 +0100
Message-ID: <CAMzoamZCXdzoxzuv_KfQsdtRa5Cc0+64N-Vodb62bJgdZeZqPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: isdn@linux-pingi.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37997 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcE3Hwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 03:52:33 -0400
Received: by mail-ig0-f171.google.com with SMTP id ph1so8465899igb.1
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 00:52:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

linux-4.7-rc1/drivers/isdn/capi/capidrv.c:1707]: (style) Redundant
condition: If 'EXPR == ' '', the comparison 'EXPR' is always true.

Source code is

   while (*s && *s == ' ') s++;

Suggest new code

   while (*s == ' ') s++;


Regards

David Binderman
