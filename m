From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_conntrack_sip: fix wrong memory
 initialisation
Date: Fri, 3 Mar 2017 13:27:18 +0100
Message-ID: <20170303122718.GA15498@salvia>
References: <20170301143327.2C90B6BD30@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Gao Feng <fgao@ikuai8.com>, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, stable@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39456 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751964AbdCCNEl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 08:04:41 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0AAD91AEA94
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 13:27:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F1E71DA7E9
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 13:27:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 90FCBDA845
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 13:27:19 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170301143327.2C90B6BD30@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 01, 2017 at 03:33:26PM +0100, Christophe Leroy wrote:
> In commit 82de0be6862cd ("netfilter: Add helper array
> register/unregister functions"),
> struct nf_conntrack_helper sip[MAX_PORTS][4] was changed to
> sip[MAX_PORTS * 4], so the memory init should have been changed to
> memset(&sip[4 * i], 0, 4 * sizeof(sip[i]));
> 
> But as the sip[] table is allocated in the BSS, it is already set to 0

Applied, thanks.
