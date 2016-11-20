From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] i40e: remove unnecessary __packed
Date: Sat, 19 Nov 2016 21:47:40 -0500 (EST)
Message-ID: <20161119.214740.728792132654733676.davem@davemloft.net>
References: <1479592438-17078-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: tushar.n.dave@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753240AbcKTCro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 21:47:44 -0500
In-Reply-To: <1479592438-17078-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>
Date: Sat, 19 Nov 2016 13:53:58 -0800

> 'struct i40e_dma_mem' defined with 'packed' directive causing kernel
> unaligned errors on sparc.

I really wish people would get out of the habit of just slapping
the __packed attribute onto structures seemingly by default.
