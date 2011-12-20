From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: tcp_mtu_probe implementation details
Date: Tue, 20 Dec 2011 14:33:01 -0800
Message-ID: <CAGK4HS93u=3muZu_rkqK7FSacTHUytK5H6_dMNo_uOQY738R_g@mail.gmail.com>
References: <op.v6s5j2i0fzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Anatoly Sivov <mm05@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40815 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab1LTWdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 17:33:02 -0500
Received: by vcbfk14 with SMTP id fk14so5293805vcb.19
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 14:33:01 -0800 (PST)
In-Reply-To: <op.v6s5j2i0fzo5me@stalin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The other question is about size_needed variable.
> It is assigned to value probe_size + (tp->reordering + 1) * tp->mss_cache
> And that is not clear for me.
> What is this "(tp->reordering + 1) * tp->mss_cache" addition?
>

I think the idea is that you want enough bytes in the write_queue so
that even if the probe is lost, the sender will get an ack even if
there is reordering in the network. Without sufficient bytes, the
probe will not be sent. This is what I make of the code but I could be
wrong.

Regards,
Vijay
