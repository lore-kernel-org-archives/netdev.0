From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp_diag: fix udp_dump_one() vs SO_REUSEPORT
Date: Tue, 05 Jan 2016 14:46:35 -0800
Message-ID: <1452033995.8255.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
	 <1452031738.8255.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452032534.8255.137.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEfhGiwM+KDGHztLKhpyKGbUizYSY8EkK5wG78or4bj9gSLyKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35025 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcAEWqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 17:46:37 -0500
Received: by mail-pf0-f179.google.com with SMTP id 78so230032734pfw.2
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:46:37 -0800 (PST)
In-Reply-To: <CAEfhGiwM+KDGHztLKhpyKGbUizYSY8EkK5wG78or4bj9gSLyKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 17:26 -0500, Craig Gallek wrote:

> Thanks Eric! Still reading through this, but I noticed a couple other
> paths as well.  Anything that comes through the exported
> udp4_lib_lookup.  Currently xt_TPROXY.c and xt_socket.c.  Though,
> these could probably be changed to pass through the skb.  That may be
> worth addressing in a separate patch, though...

Right, this will be done on a separate patch.

Note that I did not change reuseport_select_sock() yet ;)
