From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] i40e: Check for skb->queue_mapping
Date: Wed, 29 Mar 2017 17:31:30 -0700
Message-ID: <1490833890.24891.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1490831874-6396-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36691 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754231AbdC3Abd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 20:31:33 -0400
Received: by mail-pg0-f67.google.com with SMTP id 81so5711495pgh.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 17:31:32 -0700 (PDT)
In-Reply-To: <1490831874-6396-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-29 at 16:57 -0700, Tushar Dave wrote:
> There are events seen where skb->queue_mapping value is greater than
> vsi->num_queue_pairs. In such cases, vsi->tx_ring becomes invalid
> (null) and xmit results in kernel panic.
> 
> One such event is running netconsole and enabling VF on the same
> device. Or running netconsole and changing number of tx queues via
> ethtool on same device.

Something is wrong then, and must be fixed on these producers.
