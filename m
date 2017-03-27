From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/2] netfilter: Remove unnecessary cast on void pointer
Date: Mon, 27 Mar 2017 14:27:03 +0200
Message-ID: <20170327122703.GA25227@salvia>
References: <1490098794-22518-1-git-send-email-singhalsimran0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com, gregkh@linuxfoundation.org
To: simran singhal <singhalsimran0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36156 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751813AbdC0Mdt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 08:33:49 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ADDD2EAA62
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 14:27:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A08ABDA729
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 14:27:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D9DD2BAC26
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 14:27:02 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1490098794-22518-1-git-send-email-singhalsimran0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 05:49:52PM +0530, simran singhal wrote:
> This patch series remove unnecessary cast on void pointer.
> 
> simran singhal (2):
>   netfilter: ipset: Remove unnecessary cast on void pointer
>   netfilter: Remove unnecessary cast on void pointer

Please, merge this two patches in one single patch.

I have to pass up batches to David, and I would like this cleanups are
grouped into the same logical change.

Is there more occurrences of this in the Netfilter tree? Please have a
look at net/ipv4/netfilter/ net/ipv6/netfilter/ and
net/bridge/netfilter, we also have code there.

Thanks.
