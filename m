From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] ipv6: replace write lock with read lock in addrconf_permanent_addr
Date: Tue, 15 Mar 2016 08:36:52 +0800
Message-ID: <CAJFZqHzYNKBSiwV1i7qVq0QEakZYog23TqMA2vzGtAKr4A_4+Q@mail.gmail.com>
References: <1457948108-24837-1-git-send-email-roy.qing.li@gmail.com>
	<20160314.122534.345751583747280951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:36517 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbcCOAgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 20:36:53 -0400
Received: by mail-ob0-f176.google.com with SMTP id m7so1503817obh.3
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 17:36:53 -0700 (PDT)
In-Reply-To: <20160314.122534.345751583747280951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 15, 2016 at 12:25 AM, David Miller <davem@davemloft.net> wrote:
>
> We need it for the modifications made by fixup_permanent_addr().


fixup_permanent_addr should be protected by ifp->lock,
not by idev->lock write lock, since ifp is modified,

-Roy
