From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: introduce generic net_random_N helper
Date: Tue, 03 Sep 2013 06:59:44 -0700
Message-ID: <1378216784.7360.22.camel@edumazet-glaptop>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
	 <1378204010-27050-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:37113 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932710Ab3ICN7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 09:59:45 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so6074643pdi.27
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 06:59:45 -0700 (PDT)
In-Reply-To: <1378204010-27050-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 12:26 +0200, Daniel Borkmann wrote:
> We have implemented the same function over and over, so introduce a
> generic helper net_random_N() that unifies these implementations.
> It internally used net_random() which eventually resolves to
> prandom_u32(). Explicit include of reciprocal_div.h is not necessary.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---

It was private, so the name was whatever we chose at that time.

If we want to make it generic, why still doing a net_something() ?

Really this patch should be discussed on lkml and netdev and we should
use a generic name.
