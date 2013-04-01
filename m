From: Lawrence Lee <lawrenceqli@gmail.com>
Subject: How to deliver packets to the L4 layer in the NF_IP_PRE_ROUTING hook
Date: Mon, 1 Apr 2013 17:24:30 +0200
Message-ID: <CAGXkBO-ewTupoFXmq9CYeJHr9LT1QLq774LooNWMTh0j1wZwRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f180.google.com ([209.85.210.180]:53804 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757344Ab3DAPYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 11:24:31 -0400
Received: by mail-ia0-f180.google.com with SMTP id f27so1944910iae.39
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 08:24:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I  want to directly deliver some packets to the L4 layer when the
packets are in the hook of NF_IP_PRE_ROUTING. I use the use
ip_local_deliver() function. However, it does not work. May I know how
I can make it work. Thank you!

Best Regards,
Lawrence
