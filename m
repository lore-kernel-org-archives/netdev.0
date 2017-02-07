From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] Fix on-stack USB buffers
Date: Tue, 07 Feb 2017 10:07:22 -0500 (EST)
Message-ID: <20170207.100722.172401594128089212.davem@davemloft.net>
References: <20170204165451.GU3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48646 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754504AbdBGPH1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 10:07:27 -0500
In-Reply-To: <20170204165451.GU3442@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 4 Feb 2017 16:54:51 +0000

> Allocating USB buffers on the stack is not portable, and no longer
> works on x86_64 (with VMAP_STACK enabled as per default).  This
> series fixes all the instances I could find where USB networking
> drivers do that.

Series applied and queued up for -stable, thanks Ben.
