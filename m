From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/15] i40e/i40evf: organize and re-number feature
 flags
Date: Sat, 12 Aug 2017 13:04:05 -0700 (PDT)
Message-ID: <20170812.130405.1462747317744893185.davem@davemloft.net>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
        <20170812110848.18264-10-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdHLUEG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 16:04:06 -0400
In-Reply-To: <20170812110848.18264-10-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 12 Aug 2017 04:08:41 -0700

> Also ensure that the flags variable is actually a u64 to guarantee
> 64bits of space on all architectures.

Why?  You don't need 64-bits, you only need 27.

This will be unnecessarily expensive on 32-bit platforms.

Please don't do this.
