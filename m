From: Charlemagne Lasse <charlemagnelasse@gmail.com>
Subject: Re: [nf-next, 1/2] netfilter: conntrack: cache route for forwarded connections
Date: Thu, 28 Apr 2016 10:05:28 +0200
Message-ID: <CAFGhKbxZU+zHwnyJmodLL9xcUUprqxiAQBd3zjjJThRX1r==yw@mail.gmail.com>
References: <1418052964-4632-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	brouer@redhat.com, davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33620 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbcD1IFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 04:05:30 -0400
In-Reply-To: <1418052964-4632-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-12-08 16:36 GMT+01:00 Florian Westphal <fw@strlen.de>:
> ... to avoid per-packet FIB lookup if possible.
>
> The cached dst is re-used provided the input interface
> is the same as that of the previous packet in the same direction.
>
> If not, the cached dst is invalidated.

It looks like someone found out that this patch causes crashes. This
was reported to OpenWrt in ticket https://dev.openwrt.org/ticket/22283
