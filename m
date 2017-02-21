From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 2/2] netfilter: nf_ct_expect: Change
 __nf_ct_expect_check() return value.
Date: Tue, 21 Feb 2017 15:45:25 -0800
Message-ID: <CAPWQB7Go9Y1d_GkQB4z5H9acZn1UFX1CHNJDF+n1REaXp-mrMg@mail.gmail.com>
References: <1487719522-42844-1-git-send-email-jarno@ovn.org> <1487719522-42844-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, fgao@ikuai8.com,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:43116 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752000AbdBUXpv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 18:45:51 -0500
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id F320AC5A51
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 00:45:48 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id SsU8Tiezv5AX for <netdev@vger.kernel.org>;
        Wed, 22 Feb 2017 00:45:47 +0100 (CET)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 49F3FC5A4E
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 00:45:47 +0100 (CET)
Received: by mail-qk0-f174.google.com with SMTP id u188so61979383qkc.2
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 15:45:47 -0800 (PST)
In-Reply-To: <1487719522-42844-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 February 2017 at 15:25, Jarno Rajahalme <jarno@ovn.org> wrote:
> Commit 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
> returns void") inadvertently changed the successful return value of
> nf_ct_expect_related_report() from 0 to 1 due to
> __nf_ct_expect_check() returning 1 on success.  Prevent this
> regression in the future by changing the return value of
> __nf_ct_expect_check() to 0 on success.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---

It seems like other functions in this file return 0 as successful
condition, so from that perspective this seems more in line with
existing code.

Acked-by: Joe Stringer <joe@ovn.org>
