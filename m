From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 15:59:20 -0800
Message-ID: <1487462360.1311.109.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
         <58A8DD34.5040205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32975 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdBRX7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 18:59:23 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so6876581pfg.0
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 15:59:22 -0800 (PST)
In-Reply-To: <58A8DD34.5040205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-02-18 at 15:48 -0800, John Fastabend wrote:

> I'm not seeing the distinction here. If its a 4k page and
> in the stack the driver will get overrun as well.

Agree.

Using a full page per Ethernet frame does not change the attack vector.

It makes attacker job easier.
