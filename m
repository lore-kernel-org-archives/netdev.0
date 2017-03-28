From: Daurnimator <quae@daurnimator.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Wed, 29 Mar 2017 10:44:22 +1100
Message-ID: <CAEnbY+cz6jSLrqmE53nxScF92tRNv9HE7620tpjJ28E57_dPVQ@mail.gmail.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
 <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
 <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
 <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com> <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37313 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932088AbdC1XoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:44:25 -0400
Received: by mail-it0-f54.google.com with SMTP id 190so38290815itm.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:44:24 -0700 (PDT)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com. [209.85.214.49])
        by smtp.gmail.com with ESMTPSA id m125sm2812142iom.38.2017.03.28.16.44.23
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 16:44:23 -0700 (PDT)
Received: by mail-it0-f49.google.com with SMTP id 190so38290323itm.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:44:23 -0700 (PDT)
In-Reply-To: <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 March 2017 at 10:11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Should we also fix IPv6 or is this bug only about IPv4 ?

In IPv6 the second connect() returns ENETUNREACH (rather than failing
yet returning 0 as it does in IPv4).
This should probably incorrect behaviour and should the operation
should succeed.
