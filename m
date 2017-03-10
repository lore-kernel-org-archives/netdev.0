From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/5] bonding: winter cleanup
Date: Thu, 09 Mar 2017 17:33:52 -0800 (PST)
Message-ID: <20170309.173352.1958436790967931477.davem@davemloft.net>
References: <20170308185545.22864-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdCJBdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 20:33:55 -0500
In-Reply-To: <20170308185545.22864-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed,  8 Mar 2017 10:55:45 -0800

> Few cleanup patches that I have accumulated over some time now.
> 
> (a) First two patches are basically to move the work-queue initialization
>     from every ndo_open / bond_open operation to once at the beginning while
>     port creation. Work-queue initialization is an unnecessary operation
>     for every 'ifup' operation. However we have some mode-specific work-queues
>     and mode can change anytime after port creation. So the second patch is
>     to ensure the correct work-handler is called based on the mode.
> 
> (b) Third patch is simple and straightforward that removes hard-coded value
>     that was added into the initial commit and replaces it with the default
>     value configured.
> 
> (c) The final patch in the series removes the unimplemented "port-moved" state
>     from the LACP state machine. This state is defined but never set so
>     removing from the state machine logic makes code little cleaner.
> 
> (d) Reduce scope of some global variables to local.
> 
> Note: None of these patches are making any functional changes.

This series looks fine to me, applied to net-next, thanks!
