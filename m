From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: fix potential null pointer dereference
Date: Wed, 24 May 2017 11:29:30 +0200
Message-ID: <20170524092930.GA12351@salvia>
References: <20170523231837.GA9364@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56792 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031781AbdEXJ3g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 05:29:36 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 3152C1EC2C1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:29:28 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 20F611021BA
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:29:28 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2ACE1FF6FC
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:29:24 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170523231837.GA9364@embeddedgus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 06:18:37PM -0500, Gustavo A. R. Silva wrote:
> Add null check to avoid a potential null pointer dereference.
> 
> Addresses-Coverity-ID: 1408831
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

This is a fix for the net.git tree BTW.
