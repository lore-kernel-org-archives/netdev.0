From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 net-next 3/4] ipv6: Add gro functions to sit_offloads
Date: Thu, 6 Aug 2015 17:15:04 -0700
Message-ID: <CAEP_g=8tCkyRfPYARV4pqA7g0w6tQvioTnWLtFescv+3OS4JLw@mail.gmail.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com> <1438621878-1113072-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35862 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbbHGAPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 20:15:25 -0400
Received: by lagz9 with SMTP id z9so13090076lag.3
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 17:15:24 -0700 (PDT)
In-Reply-To: <1438621878-1113072-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 3, 2015 at 10:11 AM, Tom Herbert <tom@herbertland.com> wrote:
> For GRO to work with sit we need gro_receive and gro_complete populated
> in the sit_offload structure.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

You might want to checkout the recent history on this file unless
there's something that's changed in the last couple of weeks:

commit fdbf5b097bbd9693a86c0b8bfdd071a9a2117cfc
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Jul 20 17:55:38 2015 +0800

    Revert "sit: Add gro callbacks to sit_offload"

    This patch reverts 19424e052fb44da2f00d1a868cbb51f3e9f4bbb5 ("sit:
    Add gro callbacks to sit_offload") because it generates packets
    that cannot be handled even by our own GSO.

    Reported-by: Wolfgang Walter <linux@stwm.de>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>
