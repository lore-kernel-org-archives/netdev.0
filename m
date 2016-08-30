From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 nf] netfilter: log: Check param to avoid overflow in
 nf_log_set
Date: Tue, 30 Aug 2016 11:54:27 +0200
Message-ID: <20160830095427.GA20414@salvia>
References: <1472466328-5595-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34228 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752344AbcH3Jyk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 05:54:40 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6F38212A68E
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 11:54:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5DCFA114D67
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 11:54:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7A54B100A79
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 11:54:32 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1472466328-5595-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 06:25:28PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> The nf_log_set is an interface function, so it should do the strict sanity
> check of parameters. Convert the return value of nf_log_set as int instead
> of void. When the pf is invalid, return -EOPNOTSUPP.

Applied to nf-next, thanks.
