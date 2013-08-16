From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Sat, 17 Aug 2013 00:58:03 +0200
Message-ID: <125169438.hchJeoqxoY@al>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com> <2045708.ru9COLib4d@al> <1376598795.11042.1.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:42531 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701Ab3HQACY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:02:24 -0400
Received: by mail-wi0-f180.google.com with SMTP id f14so1332171wiw.13
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 17:02:22 -0700 (PDT)
In-Reply-To: <1376598795.11042.1.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 August 2013 22:33:15 Ben Hutchings wrote:
> The kernel buffer size is max(regs->len,
> dev->ethtool_ops->get_regs_len()).  So you can safely ignore regs->len
> and always read all your registers.

I see, that is something for a different patch though. While I am at it,
I checked all users of get_regs_len in drivers/net and found only one
other user that also checked the length. Patch will follow shortly.
