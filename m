From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/1] i40e: Do not enable NAPI on q_vectors that have no
 rings
Date: Fri, 24 Mar 2017 19:29:07 -0700 (PDT)
Message-ID: <20170324.192907.2169002295728740570.davem@davemloft.net>
References: <20170324220142.8921-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937053AbdCYC3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 22:29:08 -0400
In-Reply-To: <20170324220142.8921-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 24 Mar 2017 15:01:42 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> When testing the epoll w/ busy poll code I found that I could get into a
> state where the i40e driver had q_vectors w/ active NAPI that had no rings.
> This was resulting in a divide by zero error.  To correct it I am updating
> the driver code so that we only support NAPI on q_vectors that have 1 or
> more rings allocated to them.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
