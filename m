From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ibmveth: set correct gso_size and gso_type
Date: Sat, 10 Dec 2016 15:56:47 -0500 (EST)
Message-ID: <20161210.155647.1988856288960520451.davem@davemloft.net>
References: <1481333480-10827-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <1481395188-9137-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        marcelo.leitner@gmail.com, pradeeps@linux.vnet.ibm.com,
        jmaxwell37@gmail.com, zdai@us.ibm.com, eric.dumazet@gmail.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbcLJU4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 15:56:51 -0500
In-Reply-To: <1481395188-9137-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Sat, 10 Dec 2016 12:39:48 -0600

> v3: include a check for non-zero mss when calculating gso_segs
> 
> v2: calculate gso_segs after Eric Dumazet's comments on the earlier patch
>     and make sure everyone is included on CC

I already applied v1 which made it all the way even to Linus's
tree.  So you'll have to send me relative fixups if there are
things to fix or change since v1.

You must always generate patches against the current 'net' tree.
