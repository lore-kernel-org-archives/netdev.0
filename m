From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] liquidio: silence a locking static checker warning
Date: Sun, 30 Apr 2017 22:42:53 -0400 (EDT)
Message-ID: <20170430.224253.1115826536369554016.davem@davemloft.net>
References: <20170428125715.h6d5ttnfq7rdnpni@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54516 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165347AbdEACmz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:42:55 -0400
In-Reply-To: <20170428125715.h6d5ttnfq7rdnpni@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 28 Apr 2017 15:57:15 +0300

> Presumably we never hit this return, but static checkers complain that
> we need to unlock so we may as well fix that.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
