From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: dont migrate permanent fdb entries
 during learn
Date: Sun, 11 Jun 2017 19:04:16 -0400 (EDT)
Message-ID: <20170611.190416.1443081184910537296.davem@davemloft.net>
References: <1497221482-33473-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com,
        hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
        nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751912AbdFKXEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 19:04:20 -0400
In-Reply-To: <1497221482-33473-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Sun, 11 Jun 2017 15:51:22 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch fixes vxlan_snoop to not move permanent fdb entries
> on learn events. This is consistent with the bridge fdb
> handling of permanent entries.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Is there an appropriate Fixes: tag by chance?
