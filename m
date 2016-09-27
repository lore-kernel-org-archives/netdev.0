From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH v5 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
Date: Tue, 27 Sep 2016 19:39:24 +0900
Message-ID: <CANP3RGd9KguL9__r+EbiJFOsLD=Z+of+R5z-sRPXEu8jhS6DUA@mail.gmail.com>
References: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
 <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
 <1474969963-17402-4-git-send-email-zenczykowski@gmail.com> <fb240cbb-09ab-69c4-2b4c-44a50e5a308c@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:35146 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753411AbcI0Kj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 06:39:26 -0400
Received: by mail-yw0-f171.google.com with SMTP id i129so4650231ywe.2
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 03:39:26 -0700 (PDT)
In-Reply-To: <fb240cbb-09ab-69c4-2b4c-44a50e5a308c@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That wouldn't really simplify much.

This change currently has 5 lines.
3 of those would be needed anyway if we were to define anything < 0 to
mean infinite.

Yes, you could get rid of the two lines with minus_one in them, but
this way we can also use -2 to mean something else in the future if we
ever want to.
