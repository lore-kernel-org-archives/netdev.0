From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH] ipv6 addrconf: implement RFC7559 router solicitation backoff
Date: Wed, 28 Sep 2016 16:46:05 +0900
Message-ID: <CANP3RGe4jMRhepM5v2Dg4Kq3Rxj=tA7WJEMcD_83DLYcEgujMA@mail.gmail.com>
References: <1475045878-30455-1-git-send-email-zenczykowski@gmail.com> <1475048569.3276913.739336609.4398C277@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:36823 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751836AbcI1HqG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 03:46:06 -0400
Received: by mail-yb0-f173.google.com with SMTP id z8so2596356ybh.3
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 00:46:06 -0700 (PDT)
In-Reply-To: <1475048569.3276913.739336609.4398C277@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure what line you're referring to.

There are *no* outright jiffies or msecs in this patch, with the
exception of the (3600*HZ) line which is already obvious enough.

The 900000 200001 1900000 1000000 constants are not jiffies nor
miliseconds, they're simply numbers, such that 900000/1000000 = 0.9
and 200001/1000000 =~ 0.2 (the +1 is to deal with 0) and
1900000/1000000 = 1.9
