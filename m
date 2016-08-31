From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] xgbe: constify get_netdev_ops and get_ethtool_ops
Date: Wed, 31 Aug 2016 14:17:50 -0700 (PDT)
Message-ID: <20160831.141750.55012883444641424.davem@davemloft.net>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
        <20160831085736.29fc6512@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Julia.Lawall@lip6.fr, thomas.lendacky@amd.com,
        netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753280AbcHaVRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 17:17:51 -0400
In-Reply-To: <20160831085736.29fc6512@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 31 Aug 2016 08:57:36 -0700

> Casting away const is bad practice. Since this is ARM specific driver
> don't have hardware actually test this.
> 
> Having getter functions for ops is really unnecessary code bloat, but
> not going to touch that.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

I'll just apply this, let's see what happens.
