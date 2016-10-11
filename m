From: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: Re: saddr based blackhole/unreachable route
Date: Wed, 12 Oct 2016 00:13:12 +0200
Message-ID: <CAJO99T=kb+sMpaZQ7FqqUW7hZXmZosuyom0DZV1_8UmbCYHUwQ@mail.gmail.com>
References: <CAJO99Tn7oaGEhRKEBR83K_+JSJUaFXEqvMnbM3vOLVxDqF9wtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34193 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753367AbcJKWNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 18:13:14 -0400
Received: by mail-yw0-f171.google.com with SMTP id w3so22445433ywg.1
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 15:13:14 -0700 (PDT)
In-Reply-To: <CAJO99Tn7oaGEhRKEBR83K_+JSJUaFXEqvMnbM3vOLVxDqF9wtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-10-11 20:39 GMT+02:00 Bj=C3=B8rnar Ness <bjornar.ness@gmail.com>:
> Hello, netdev
>
> In a typical setup (eth0=3Dinternet, eth1=3Dlan) i populate routing table
> 100 with saddrs I want
> dropped, and: "ip ru a pref 100 lookup table 100"
>
> What I would expect to see is packets with a saddr in table 100 coming
> in eth0 will go out eth1,
> with replies beeing dropped, but I do not see the packets going out eth1 =
at all.
>
> Have tried searching and following the fib codepath, but have still
> not managed to understand what is really going on here.

Answering my own question, I guess its rp_filter kicking in here. and
it also explains
why I dont get icmp unreachable

Is there a better way to do source based rtbh?

--=20
Bj(/)rnar
