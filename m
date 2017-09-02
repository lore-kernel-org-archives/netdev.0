From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Sat, 2 Sep 2017 16:01:29 -0700
Message-ID: <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35204 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752761AbdIBXBv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 19:01:51 -0400
Received: by mail-lf0-f43.google.com with SMTP id g18so10239560lfl.2
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 16:01:51 -0700 (PDT)
In-Reply-To: <87fuc7ong0.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 6:51 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Saeed Mahameed <saeedm@mellanox.com> writes:
>
>> The first patch from Gal and Ariel provides the mlx5 driver support for
>> ConnectX capability to perform IP version identification and matching in
>> order to distinguish between IPv4 and IPv6 without the need to specify the
>> encapsulation type, thus perform RSS in MPLS automatically without
>> specifying MPLS ethertyoe. This patch will also serve for inner GRE IPv4/6
>> classification for inner GRE RSS.
>
> I don't think this is legal at all or did I misunderstood something?
>
> <https://tools.ietf.org/html/rfc3032#section-2.2>

It seems you misunderstood the cover letter.  The HW will still
identify MPLS (IPv4/IPv6) packets using a new bit we specify in the HW
steering rules rather than adding new specific rules with  {MPLS
ethertype} X {IPv4,IPv6} to classify MPLS IPv{4,6} traffic, Same
functionality a better and general way to approach it.
Bottom line the hardware is capable of processing MPLS headers and
perform RSS on the inner packet (IPv4/6) without the need of the
driver to provide precise steering MPLS rules.

>
> Thanks,
> Hannes
