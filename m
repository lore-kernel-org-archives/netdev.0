From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] dccp/tcp: fix ireq->opt races
Date: Thu, 19 Oct 2017 07:45:09 -0700
Message-ID: <CANn89i+=3B-i1Fo=8PWwzXJ-Tn7x8uOL7oQ02Bvx0e-KrdUQFw@mail.gmail.com>
References: <1508269526.31614.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <20171019.133138.1755187507720163652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:51454 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdJSOpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 10:45:10 -0400
Received: by mail-yw0-f179.google.com with SMTP id k3so3693871ywk.8
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 07:45:10 -0700 (PDT)
In-Reply-To: <20171019.133138.1755187507720163652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 5:31 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 17 Oct 2017 12:45:26 -0700
>
>> syzkaller found another bug in DCCP/TCP stacks [1]
>>
>> For the reasons explained in commit ce1050089c96 ("tcp/dccp: fix
>> ireq->pktopts race"), we need to make sure we do not access
>> ireq->opt unless we own the request sock.
>
> This doesn't apply to 'net'.
>
> [davem@kkuri net]$ git am --signoff v2-net-dccp-tcp-fix-ireq--opt-races.patch
> Applying: dccp/tcp: fix ireq->opt races
> error: patch failed: include/net/inet_sock.h:96
> error: include/net/inet_sock.h: patch does not apply
> error: patch failed: net/dccp/ipv4.c:414
> error: net/dccp/ipv4.c: patch does not apply
> error: patch failed: net/ipv4/inet_connection_sock.c:540
> error: net/ipv4/inet_connection_sock.c: patch does not apply
> error: patch failed: net/ipv4/syncookies.c:355
> error: net/ipv4/syncookies.c: patch does not apply
> error: patch failed: net/ipv4/tcp_input.c:6196
> error: net/ipv4/tcp_input.c: patch does not apply
> error: patch failed: net/ipv4/tcp_ipv4.c:877
> error: net/ipv4/tcp_ipv4.c: patch does not apply

Can you send me this v2-net-dccp-tcp-fix-ireq--opt-races.patch file ?

Here the patch applies fine.

Thanks !
