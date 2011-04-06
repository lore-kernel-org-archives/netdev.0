From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 3/9] tg3: Reintroduce 5717_PLUS
Date: Tue, 05 Apr 2011 22:30:53 -0700
Message-ID: <1302067853.1683.29.camel@Joe-Laptop>
References: <1302049371-13799-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4543 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab1DFFay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 01:30:54 -0400
In-Reply-To: <1302049371-13799-4-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-05 at 17:22 -0700, Matt Carlson wrote:
> This patch reintroduces the TG3_FLG3_5717_PLUS to identify 5717 and
> later devices.
[]
> @@ -13427,8 +13422,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
[]
> +	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
>  		tp->tg3_flags3 |= TG3_FLG3_LRG_PROD_RING_CAP;

This seems redundant.  Maybe consolidate to just
TG3_FLG3_5717_PLUS and remove LRG_PROD_RING_CAP?

I don't know if these attributes really are linked.

Another option may be to use DECLARE_BITMAP
and set_bit/test_bit so there's no real need
to use FLAG/FLG2/FLG3, etc.


