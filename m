From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 1/2] netfilter: nf_ct_expect: nf_ct_expect_related_report():
 Return zero on success,
Date: Tue, 21 Feb 2017 15:41:22 -0800
Message-ID: <CAPWQB7E=TNYPsFYNgyCanCi3M9-=KbpsbDeKCFrWFBYdQF5Ubw@mail.gmail.com>
References: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, fgao@ikuai8.com,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:59920 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752738AbdBUXls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 18:41:48 -0500
Received: from mfilter13-d.gandi.net (mfilter13-d.gandi.net [217.70.178.141])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 7D243FB881
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 00:41:45 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter13-d.gandi.net (mfilter13-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id rG4HAZ33nL_M for <netdev@vger.kernel.org>;
        Wed, 22 Feb 2017 00:41:43 +0100 (CET)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
        (Authenticated sender: joe@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 8AB0EFB886
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 00:41:43 +0100 (CET)
Received: by mail-qk0-f176.google.com with SMTP id x71so71718700qkb.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 15:41:43 -0800 (PST)
In-Reply-To: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 February 2017 at 15:25, Jarno Rajahalme <jarno@ovn.org> wrote:
> Commit 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
> returns void") inadvertently changed the successful return value of
> nf_ct_expect_related_report() from 0 to 1, which caused openvswitch
> conntrack integration fail in FTP test cases.

I can't tell at a glance given all the netlink callback stuff but I
suspect this broke expectation insertion from netlink too.

> Fix this by always returning zero on the success code path.
>
> Fixes: 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert() returns void")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
