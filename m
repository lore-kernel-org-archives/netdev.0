From: Lin Ming <minggr@gmail.com>
Subject: Why UDP can't confirm ARP state?
Date: Sat, 17 Aug 2013 01:07:19 +0800
Message-ID: <CAF1ivSZ=f_swEhaeEtbdkbVu=e1ZUSw=e0BF6+TZXW=HoTk0EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:42455 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab3HPRHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 13:07:20 -0400
Received: by mail-la0-f48.google.com with SMTP id er20so1692424lab.35
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 10:07:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

When TCP receives a packet, it can confirm the related ARP cache entry
in REACHABLE state.
Why can't UDP?

I think it's because UDP is connectionless.
But I don't get the exact reason.

Any hint?

Thanks,
Lin Ming
