From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/7][pull request] 100GbE Intel Wired LAN Driver
 Updates 2017-04-05
Date: Thu, 06 Apr 2017 13:53:35 -0700 (PDT)
Message-ID: <20170406.135335.257255975544577212.davem@davemloft.net>
References: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752018AbdDFUxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:53:37 -0400
In-Reply-To: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  6 Apr 2017 00:54:49 -0700

> This series contains updates to fm10k only.
> 
> Phil Turnbull from Oracle fixes an issue where the argument provided to
> FM10K_REMOVED macro was not what was expecting.
> 
> Jake modifies the driver to replace the bitwise operators and defines with
> a BITMAP and enumeration values to avoid race conditions.  Also future
> proof the driver so that developers do not have to remember to re-size the
> bitmaps when adding new values.  Fixed the wording of a code comment to
> avoid stating that we return a value for a void function.
> 
> Ngai-Mint makes sure that when configuring the receive ring, we make sure
> the receive queue is disabled.  Fixed an issue where interfaces were
> resetting because the transmit mailbox FIFO was becoming full since the
> host was not ready, so ensure the host is ready before queueing up
> mailbox messages.

Pulled, thanks Jeff.
