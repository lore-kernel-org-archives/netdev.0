From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: dont migrate permanent fdb entries
 during learn
Date: Mon, 12 Jun 2017 11:01:14 -0400 (EDT)
Message-ID: <20170612.110114.2032630343661245925.davem@davemloft.net>
References: <1497223970-40084-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com,
        hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
        nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752159AbdFLPBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 11:01:16 -0400
In-Reply-To: <1497223970-40084-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Sun, 11 Jun 2017 16:32:50 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch fixes vxlan_snoop to not move permanent fdb entries
> on learn events. This is consistent with the bridge fdb
> handling of permanent entries.
> 
> Fixes: 26a41ae60438 ("vxlan: only migrate dynamic FDB entries")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v2 - added Fixes tag

Applied, thank you.
