From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [net:master 9/12] net/ipv6/ip6_offload.c:120:7-21: WARNING:
 Unsigned expression compared with zero: unfrag_ip6hlen < 0 (fwd)
Date: Thu, 18 May 2017 08:57:32 -0400
Message-ID: <CAEfhGizhMTzOiPUPH978Fo9-K9eBhEOaAKHoDLVHYOtOF_c_HQ@mail.gmail.com>
References: <alpine.DEB.2.20.1705181000150.3833@hadrien> <20170517.225831.2041930111066229998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: julia.lawall@lip6.fr, netdev <netdev@vger.kernel.org>,
        kbuild-all@01.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:35775 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754641AbdERM5f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 08:57:35 -0400
Received: by mail-qt0-f181.google.com with SMTP id v27so33048370qtg.2
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 05:57:35 -0700 (PDT)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com. [209.85.220.177])
        by smtp.gmail.com with ESMTPSA id c15sm3693902qte.25.2017.05.18.05.57.33
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 05:57:33 -0700 (PDT)
Received: by mail-qk0-f177.google.com with SMTP id a72so34599517qkj.2
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 05:57:33 -0700 (PDT)
In-Reply-To: <20170517.225831.2041930111066229998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 17, 2017 at 10:58 PM, David Miller <davem@davemloft.net> wrote:
> From: Julia Lawall <julia.lawall@lip6.fr>
> Date: Thu, 18 May 2017 10:01:07 +0800 (SGT)
>
>> It may be worth checking on these.  The code context is shown in the first
>> case (line 120).  For the others, at least it gives the line numbers.
>  ...
>>>> net/ipv6/ip6_offload.c:120:7-21: WARNING: Unsigned expression compared with zero: unfrag_ip6hlen < 0
>> --
>>>> net/ipv6/ip6_output.c:601:5-9: WARNING: Unsigned expression compared with zero: hlen < 0
>> --
>>>> net/ipv6/udp_offload.c:94:6-20: WARNING: Unsigned expression compared with zero: unfrag_ip6hlen < 0
>
> Sigh, this is worse than the bug the commit introducing these warnings
> was trying to fix.
Thanks for the fix, sorry I missed this.
