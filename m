From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] Revert "net: Remove state argument from skb_find_text()"
Date: Tue, 7 Feb 2017 13:36:16 +0100
Message-ID: <20170207123616.GA2607@salvia>
References: <1486273710-18457-1-git-send-email-igor.pylypiv@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Igor Pylypiv <igor.pylypiv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54622 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752833AbdBGMga (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 07:36:30 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ACE121B7FB7
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 13:36:28 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 98F8EDA858
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 13:36:28 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 745C4DA804
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 13:36:26 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1486273710-18457-1-git-send-email-igor.pylypiv@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 09:48:30PM -0800, Igor Pylypiv wrote:
> This reverts commit 059a2440fd3cf4ec57735db2c0a90401cde84fca.
> 
> Textsearch state parameter should be passed by pointer because
> its resulting value is needed for call to textsearch_next().

You're right this renders textsearch_next() useless.

But I remember David took this one time ago because there are no
clients for textsearch_next() in the tree, apart from
textsearch_find().

Am I missing anything?

Thanks.
