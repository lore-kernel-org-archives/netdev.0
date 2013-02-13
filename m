From: Felipe Dias <felipediassss@gmail.com>
Subject: Re: dev_add_pack() duplicate skb ?
Date: Wed, 13 Feb 2013 14:09:30 -0200
Message-ID: <CAJX4=r3VobFsBkaykQJyC4g_G9hgdRmO_XpDL3ppUnfM1eY0cw@mail.gmail.com>
References: <CAJX4=r08yC7PPtO7KA-3rsY5SMsZueJ=tVDdi2HT6MvnuO1ung@mail.gmail.com>
	<1360767925.6884.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f66.google.com ([209.85.219.66]:38978 "EHLO
	mail-oa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934116Ab3BMQJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 11:09:31 -0500
Received: by mail-oa0-f66.google.com with SMTP id h2so390333oag.9
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 08:09:31 -0800 (PST)
In-Reply-To: <1360767925.6884.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2013 at 1:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-02-13 at 10:11 -0200, Felipe Dias wrote:
>> This show 4 packets in ipv4 too. What I'm doing wrong ?
>
> The ICMP request is sent, _and_ received : 2 packets
> The ICMP response is sent, _and_ received : 2 packets
>
> Total : 4 packets.
>
> af_packet has special code to avoid seeing packets twice on loopback, as
> it would be a bit annoying.
Of course. Thank you so much.

Att
fd.
