From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv6: Compare lwstate in detecting duplicate nexthops
Date: Wed, 5 Jul 2017 14:14:33 -0700
Message-ID: <CAJieiUji4hOeRXZoCXfiC6p5NYzeqO_Ou0RYzarX2afXgLzcqA@mail.gmail.com>
References: <20170705204146.5263-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Lennert Buytenhek <buytenh@wantstofly.org>,
        Robert Shearman <rshearma@brocade.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:35601 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751796AbdGEVOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 17:14:49 -0400
Received: by mail-ua0-f178.google.com with SMTP id j53so767333uaa.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 14:14:44 -0700 (PDT)
In-Reply-To: <20170705204146.5263-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 1:41 PM, David Ahern <dsahern@gmail.com> wrote:
> Lennert reported a failure to add different mpls encaps in a multipath
> route:
>
>   $ ip -6 route add 1234::/16 \
>         nexthop encap mpls 10 via fe80::1 dev ens3 \
>         nexthop encap mpls 20 via fe80::1 dev ens3
>   RTNETLINK answers: File exists
>
> The problem is that the duplicate nexthop detection does not compare
> lwtunnel configuration. Add it.
>
> Fixes: 19e42e451506("ipv6: support for fib route lwtunnel encap attribute=
s")
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---


Reported-by: Jo=C3=A3o Taveira Ara=C3=BAjo <joao.taveira@gmail.com>

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
