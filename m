From: David Held <drheld@google.com>
Subject: Re: [PATCH net-next v2 0/2] udp: Fix multicast performance issues.
Date: Tue, 15 Jul 2014 17:23:53 -0400
Message-ID: <CAGa1Tm6Zx8AzRY+exwGRnbYSA51fhYXDQ3qSNkmyPL99jeYn9w@mail.gmail.com>
References: <1405459363-3047-1-git-send-email-drheld@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:41897 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755815AbaGOVXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 17:23:54 -0400
Received: by mail-ie0-f178.google.com with SMTP id tp5so4889750ieb.23
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 14:23:54 -0700 (PDT)
In-Reply-To: <1405459363-3047-1-git-send-email-drheld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2
 - updated hash collision detection

On Tue, Jul 15, 2014 at 5:22 PM, David Held <drheld@google.com> wrote:
> Fix performance issues with listening to many different multicast
> sockets on different addresses with the same port. Instead of always
> using hash1, fall back to hash2 lookup when hash1 lookup is long.
> Patch 1 is a general cleanup and simplification which also makes the
> main implementation in Patch 2 simpler.
>
> Eric's recent change 63c6f81cdde5 avoided this being an issue in early
> demux. This makes it work for regular delivery as well.
>
