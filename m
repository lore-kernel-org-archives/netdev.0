From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH 5/7] ipv6 addrconf: implement RFC7559 router solicitation backoff
Date: Sun, 25 Sep 2016 11:14:01 +0900
Message-ID: <CAHo-OowM540xrLpQTcK5nZPO9OgALsJb4QVJpgH_DtGKmLugiw@mail.gmail.com>
References: <CAHo-Oozocj2rzY8hTTr1f3roMy9iz50j6X=dBG5qmz4B_LFAFQ@mail.gmail.com>
 <1474733109-18355-1-git-send-email-zenczykowski@gmail.com> <1474733109-18355-5-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f178.google.com ([209.85.213.178]:35535 "EHLO
        mail-yb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965459AbcIYCOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 22:14:02 -0400
Received: by mail-yb0-f178.google.com with SMTP id t5so1643288yba.2
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 19:14:02 -0700 (PDT)
In-Reply-To: <1474733109-18355-5-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, so that seems to have all sorts of __divdi3 or __aeabi_ldivmod
undefined errors on 32-bit platforms (ie. arm/m68k/i386).
