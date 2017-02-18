From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] ipv6: release dst on error in ip6_dst_lookup_tail
Date: Sat, 18 Feb 2017 18:58:17 -0500
Message-ID: <CAF=yD-JSfjp+pX+9xoeOtLnTjZJjjMJmwhf_m2PFPZzLEPmH3Q@mail.gmail.com>
References: <20170218235144.29670-1-willemdebruijn.kernel@gmail.com> <1487462207.1311.107.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, jtleight@udel.edu,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37181 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdBRX7A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 18:59:00 -0500
Received: by mail-wm0-f45.google.com with SMTP id v77so31094751wmv.0
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 15:58:59 -0800 (PST)
In-Reply-To: <1487462207.1311.107.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But looks like the commit sha1 was
> ec5e3b0a1d41fbda0cc33a45bc9e54e91d9d12c7
>
> So the correct tag would be
>
> Fixes: ec5e3b0a1d41 ("ipv6: Inhibit IPv4-mapped src address on the wire.")

Thanks for catching that! I'll send a v2 with the fixed commit.
