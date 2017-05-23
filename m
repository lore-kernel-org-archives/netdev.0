From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make struct request_sock_ops::obj_size unsigned
Date: Tue, 23 May 2017 11:13:48 -0400 (EDT)
Message-ID: <20170523.111348.1436288697755101399.davem@davemloft.net>
References: <20170522212139.GB28769@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967025AbdEWPNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:13:50 -0400
In-Reply-To: <20170522212139.GB28769@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 23 May 2017 00:21:39 +0300

> This field is sizeof of corresponding kmem_cache so it can't be negative.
> 
> Space will be saved after 32-bit kmem_cache_create() patch.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
