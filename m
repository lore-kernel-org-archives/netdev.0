From: David Miller <davem@davemloft.net>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Wed, 15 Mar 2017 14:55:12 -0700 (PDT)
Message-ID: <20170315.145512.1542025976162251828.davem@davemloft.net>
References: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com>
        <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com>
        <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, daniel@iogearbox.net, mgherzan@gmail.com,
        netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        linux-arm-kernel@lists.infradead.org
To: illusionist.neo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54496 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753314AbdCOVzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 17:55:13 -0400
In-Reply-To: <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shubham Bansal <illusionist.neo@gmail.com>
Date: Wed, 15 Mar 2017 17:43:44 +0530

>> You can't truncate, but you'll have to build 64-bit ops using 32-bit registers.
> 
> A small example would help a lot.

You can simply perform 64-bit operations in C code and see what gcc
outputs for that code on this 32-bit target.
