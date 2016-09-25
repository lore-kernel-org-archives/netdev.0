From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf v5] netfilter: seqadj: Fix the wrong ack adjust for
 the RST packet without ack
Date: Sun, 25 Sep 2016 13:31:53 +0200
Message-ID: <20160925113153.GA8331@salvia>
References: <1474527233-21988-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38128 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965662AbcIYLcE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 07:32:04 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AB9F5ED07F
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 13:32:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9C0A5DA84E
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 13:32:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BA3A1DA817
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 13:31:58 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1474527233-21988-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016 at 02:53:53PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> It is valid that the TCP RST packet which does not set ack flag, and bytes
> of ack number are zero. But current seqadj codes would adjust the "0" ack
> to invalid ack number. Actually seqadj need to check the ack flag before
> adjust it for these RST packets.

Applied, thanks.
