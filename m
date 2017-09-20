From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 12/14] gtp: Configuration for zero UDP checksum
Date: Wed, 20 Sep 2017 11:09:29 -0700
Message-ID: <CALx6S35NP_BJ8oHwjkOZkNYJa=g7hWeUiNMZ5WNj-2FQaksCeQ@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-13-tom@quantonium.net>
 <20170918.212445.1680068602644706922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        Rohit Seth <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:44234 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbdITSJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 14:09:30 -0400
Received: by mail-qk0-f170.google.com with SMTP id b23so3559358qkg.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 11:09:30 -0700 (PDT)
In-Reply-To: <20170918.212445.1680068602644706922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 9:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@quantonium.net>
> Date: Mon, 18 Sep 2017 17:39:02 -0700
>
>> Add configuration to control use of zero checksums on transmit for both
>> IPv4 and IPv6, and control over accepting zero IPv6 checksums on
>> receive.
>>
>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>
> I thought we were trying to move away from this special case of allowing
> zero UDP checksums with tunnels, especially for ipv6.

I don't have a strong preference either way. I like consistency with
VXLAN and foo/UDP, but I guess it's not required. Interestingly, since
GTP only carries IP, IPv6 zero checksums are actually safer here than
VXLAN or GRE/UDP.

Tom
