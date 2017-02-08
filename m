From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: fix description of skb_find_text() according to
 removed functionality
Date: Wed, 8 Feb 2017 09:44:55 +0100
Message-ID: <20170208084455.GA1878@salvia>
References: <20170207.105320.45609559819874123.davem@davemloft.net>
 <1486521937-10638-1-git-send-email-igor.pylypiv@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Igor Pylypiv <igor.pylypiv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43544 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753944AbdBHJJG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 04:09:06 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id DED5211A104
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 09:45:02 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D0D0ADA819
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 09:45:02 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 811F4DA81A
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 09:45:00 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1486521937-10638-1-git-send-email-igor.pylypiv@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 06:45:37PM -0800, Igor Pylypiv wrote:
> Textsearch state parameter was moved to local scope of the function.
> This eliminates usage of textsearch_next() to find subsequent occurrences.
> 
> Fixes: 59a2440fd3cf ("net: Remove state argument from skb_find_text()")
> Signed-off-by: Igor Pylypiv <igor.pylypiv@gmail.com>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
