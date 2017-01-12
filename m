From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Initialize mbox lock and list for mgmt
 dev
Date: Thu, 12 Jan 2017 09:24:06 -0500 (EST)
Message-ID: <20170112.092406.508771101561313807.davem@davemloft.net>
References: <1484204001-19013-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        hariprasad@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdALOYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:24:09 -0500
In-Reply-To: <1484204001-19013-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu, 12 Jan 2017 12:23:21 +0530

> Initialize mbox lock and list for mgmt dev to avoid NULL pointer
> dereference when cxgb_set_vf_mac is called.
> 
> And also allocate memory for private data while allocating mgmt
> netdev.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
