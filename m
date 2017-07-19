From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wireless: wext: terminate ifr name coming from
 userspace
Date: Wed, 19 Jul 2017 13:33:50 -0700 (PDT)
Message-ID: <20170719.133350.2148731138543152927.davem@davemloft.net>
References: <20170718042318.5309-1-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: alexander.levin@verizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932147AbdGSUdv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 16:33:51 -0400
In-Reply-To: <20170718042318.5309-1-alexander.levin@verizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Date: Tue, 18 Jul 2017 04:23:16 +0000

> ifr name is assumed to be a valid string by the kernel, but nothing
> was forcing username to pass a valid string.
> 
> In turn, this would cause panics as we tried to access the string
> past it's valid memory.
> 
> Signed-off-by: Sasha Levin <alexander.levin@verizon.com>

Applied and queued up for -stable.

dev_ifname() has the same bug, I'll post a patch for that.
