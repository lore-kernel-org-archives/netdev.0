From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vxlan: fix a potential issue when create a new
 vxlan fdb entry.
Date: Wed, 30 Nov 2016 12:03:12 -0500 (EST)
Message-ID: <20161130.120312.1290411449256338013.davem@davemloft.net>
References: <1480384776-8252-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, hannes@stressinduktion.org, pshelar@nicira.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758277AbcK3RDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:03:16 -0500
In-Reply-To: <1480384776-8252-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Tue, 29 Nov 2016 09:59:36 +0800

> vxlan_fdb_append may return error, so add the proper check,
> otherwise it will cause memory leak.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> Changes in v2:
>   - Unnecessary to initialize rc to zero.

Applied, thanks.
