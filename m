From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 2/2] netfilter: nf_ct_expect: Change
 __nf_ct_expect_check() return value.
Date: Wed, 22 Feb 2017 10:47:44 +0100
Message-ID: <20170222094744.GD1581@salvia>
References: <1487719522-42844-1-git-send-email-jarno@ovn.org>
 <1487719522-42844-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fgao@ikuai8.com
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60190 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754529AbdBVJr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Feb 2017 04:47:59 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 973C01395CD
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 10:47:57 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 86641DA80C
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 10:47:57 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4C1D6DA86E
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 10:47:55 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1487719522-42844-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 03:25:22PM -0800, Jarno Rajahalme wrote:
> Commit 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
> returns void") inadvertently changed the successful return value of
> nf_ct_expect_related_report() from 0 to 1 due to
> __nf_ct_expect_check() returning 1 on success.  Prevent this
> regression in the future by changing the return value of
> __nf_ct_expect_check() to 0 on success.

Same thing, please Cc netfilter-devel. Thanks.
