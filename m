From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: Initialize vlan_features to turn on
 offload support.
Date: Thu, 31 Jul 2014 22:10:24 -0700 (PDT)
Message-ID: <20140731.221024.1202420334486041465.davem@davemloft.net>
References: <1406817025-17738-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbaHAFKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:10:24 -0400
In-Reply-To: <1406817025-17738-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 31 Jul 2014 10:30:25 -0400

> Macvlan devices do not initialize vlan_features.  As a result,
> any vlan devices configured on top of macvlans perform very poorly.
> Initialize vlan_features based on the vlan features of the lower-level
> device.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks.
