From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Mon, 19 Jan 2015 01:31:24 -0800
Message-ID: <CAE4R7bCThwbQ80kYbY9rNhLOyjzs6eONKiOoQR=K8CrLARDF1A@mail.gmail.com>
References: <E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org>
	<CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
	<01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
	<20150118.233722.226468667930444145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Tom Gundersen <teg@jklm.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:33852 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbbASJbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 04:31:25 -0500
Received: by mail-wg0-f46.google.com with SMTP id x13so30606473wgg.5
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 01:31:24 -0800 (PST)
In-Reply-To: <20150118.233722.226468667930444145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2015 at 8:37 PM, David Miller <davem@davemloft.net> wrote:
>
> ====================
> [PATCH] netlink: Fix bugs in nlmsg_end() conversions.
>
> Commit 053c095a82cf ("netlink: make nlmsg_end() and genlmsg_end()
> void") didn't catch all of the cases where callers were breaking out
> on the return value being equal to zero, which they no longer should
> when zero means success.
>
> Fix all such cases.
>
> Reported-by: Marcel Holtmann <marcel@holtmann.org>
> Reported-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Fixes my tests, so I'm happy.  Thank you.

Acked-by: Scott Feldman <sfeldma@gmail.com>
