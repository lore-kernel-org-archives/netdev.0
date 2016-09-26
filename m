From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH v4 2/7] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
Date: Mon, 26 Sep 2016 18:37:37 +0900
Message-ID: <CANP3RGdL_N_vV1iXoCVz+Gu-oTSm8y2Y=dkx1APmb+z6sJ8S=A@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-3-git-send-email-zenczykowski@gmail.com>
 <CAAedzxoD6DiNDQUpuiV3tQV0zVmAb=J6968aU02Z+3521u0s3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f181.google.com ([209.85.213.181]:35202 "EHLO
        mail-yb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760834AbcIZJhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:37:39 -0400
Received: by mail-yb0-f181.google.com with SMTP id t5so9752896yba.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:37:38 -0700 (PDT)
In-Reply-To: <CAAedzxoD6DiNDQUpuiV3tQV0zVmAb=J6968aU02Z+3521u0s3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +static int one = 1;
>> +static int two_five_five = 255;
>
> Should these be const as well?

It would be nice, but you actually get compile time warnings if you do that.
