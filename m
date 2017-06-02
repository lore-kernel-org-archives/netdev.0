From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: avoid enabling napi twice to the same queue
Date: Fri, 02 Jun 2017 14:06:53 -0400 (EDT)
Message-ID: <20170602.140653.304259096877708455.davem@davemloft.net>
References: <1496235388-20496-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, indranil@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45924 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdFBSGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:06:55 -0400
In-Reply-To: <1496235388-20496-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Wed, 31 May 2017 18:26:28 +0530

> Take uld mutex to avoid race between cxgb_up() and
> cxgb4_register_uld() to enable napi for the same uld
> queue.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied and queued up for -stable, thanks.
