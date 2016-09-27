From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH v2 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
Date: Tue, 27 Sep 2016 11:23:15 +0900
Message-ID: <CANP3RGdqvWsRRW=UFnC=z+1QDSajsfmswjs+BZB8jB+1NkGiqQ@mail.gmail.com>
References: <20160925.053302.1895311145903319224.davem@davemloft.net>
 <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
 <1474797596-13320-3-git-send-email-zenczykowski@gmail.com> <CAKD1Yr2MHqFMmJyf89pWzopcr07ziVcHqUB+oNWdphKx95nGDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34820 "EHLO
        mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753989AbcI0CXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 22:23:17 -0400
Received: by mail-yw0-f177.google.com with SMTP id u82so202532ywc.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 19:23:16 -0700 (PDT)
In-Reply-To: <CAKD1Yr2MHqFMmJyf89pWzopcr07ziVcHqUB+oNWdphKx95nGDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Given that some of this patch checks for == -1, and some of it checks
> for != 0... is it possible that setting the value to something
> unexpected like -3 will cause any issues to the stack? (Other than
> just rendering IPv6 unusable on this interface, which seems like a
> given.)

You shouldn't be able to set it to -3, that's what the extra1 is for...
