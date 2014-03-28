From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] Audit all drivers for correct vlan_features.
Date: Fri, 28 Mar 2014 17:17:35 -0400 (EDT)
Message-ID: <20140328.171735.920277679887549956.davem@davemloft.net>
References: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbaC1VRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:17:38 -0400
In-Reply-To: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 27 Mar 2014 22:14:45 -0400

> Some drivers set vlan acceleration features in vlan_features.  This causes
> issues with Q-in-Q/802.1ad configurations.
> 
> Audit all the drivers for correct vlan_features.  Fix broken ones.
> Add a warning to vlan code to help catch future offenders.
> 
> Vlad Yasevich (4):
>   qlge: Do not propaged vlan tag offloads to vlans
>   ifb: Remove vlan acceleration from vlan_features
>   veth: Turn off vlan rx acceleration in vlan_features
>   vlan: Mask off vlan acceleration features on vlan device.

Excellent work, thanks for doing this Vlad!

Applied.
