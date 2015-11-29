From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: TUN interfaces loopback
Date: Sun, 29 Nov 2015 17:40:20 +0900
Message-ID: <CAKD1Yr1eh5nawO3793Z61-UOYr5uXiT8FFksGeEZ2F1A8e=u3g@mail.gmail.com>
References: <1448470693.7801.41.camel@mindbit.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Radu Rendec <radu.rendec@mindbit.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:34937 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbbK2Ikl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 03:40:41 -0500
Received: by ykba77 with SMTP id a77so154313052ykb.2
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 00:40:40 -0800 (PST)
In-Reply-To: <1448470693.7801.41.camel@mindbit.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 26, 2015 at 1:58 AM, Radu Rendec <radu.rendec@mindbit.ro> wrote:
> I tracked down the problem to ip_route_input_slow() in net/ipv4/route.c
> [...]
> The next problem is that packets are seen as "martians" and dropped,
> most probably because of __fib_validate_source() failing due to the
> fact that the input interface is not the expected one.

Have you tried setting this?

accept_local - BOOLEAN
        Accept packets with local source addresses. In combination with
        suitable routing, this can be used to direct packets between two
        local interfaces over the wire and have them accepted properly.
        default FALSE
