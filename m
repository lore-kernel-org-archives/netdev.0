From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: remove unused ifla_stats_policy
Date: Thu, 08 Sep 2016 17:23:19 -0700 (PDT)
Message-ID: <20160908.172319.506563196312084552.davem@davemloft.net>
References: <20160907135736.7a986302@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIAXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:23:20 -0400
In-Reply-To: <20160907135736.7a986302@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 7 Sep 2016 13:57:36 -0700

> This structure is defined but never used. Flagged with W=1
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

This comes from commit 10c9ead9f3c6bb24bddc9a96681f7d58e6623966
("rtnetlink: add new RTM_GETSTATS message to dump link stats")

Roopa, did you intentionally put this here unreferenced for the
purposes or documentation or something like that?
