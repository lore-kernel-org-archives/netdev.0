From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: allow CAP_NET_RAW to setsockopt SO_PRIORITY
Date: Mon, 24 Oct 2011 23:30:55 -0700
Message-ID: <CAHo-OowQakvfW_T0uPgBaUCheMehTzyGnOp0hqC+-SNdJVBjMg@mail.gmail.com>
References: <1319518038-28679-1-git-send-email-zenczykowski@gmail.com>
	<20111025.005819.456617923859129015.davem@davemloft.net>
	<CANP3RGfdimCqGL=kdVQdYY0KHqVuVL3CL6arRh3EhdNhyrv9cw@mail.gmail.com>
	<20111025.022546.1784159727449615100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56913 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab1JYGa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 02:30:56 -0400
Received: by qabj40 with SMTP id j40so83410qab.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 23:30:56 -0700 (PDT)
In-Reply-To: <20111025.022546.1784159727449615100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> SO_PRIORITY can control prioritizations that are not influenced
> by packet contents.
>
> There is a huge difference.

I do agree that it can do that, but I'm not sure the difference is
huge as you so put it.
In the vast majority of cases prioritization is desired based on some
meaningful aspect
of a packet that can also be observed later on in the network - hence
vlan tags, tos/tclass marks,
protocol, port numbers and the like.

I guess to me, in the real world (or at least the portion of it I'm
aware of), the difference is minor at best.

Being able to select xmit queues, is kind of like being able to select
output device.
You give a CAP_NET_RAW process raw access to the wire - prioritization seems
just one more aspect of this.  Especially since this isn't permanently
reconfiguring anything.

Anyway, enough discussion ;-)

Cheers,
Maciej
