From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] vlan: Mask off vlan acceleration features on
 vlan device.
Date: Wed, 26 Mar 2014 17:10:38 -0400 (EDT)
Message-ID: <20140326.171038.2150319831233512825.davem@davemloft.net>
References: <1395865521-2318-1-git-send-email-vyasevic@redhat.com>
	<1395865711-3347-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbaCZVKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:10:40 -0400
In-Reply-To: <1395865711-3347-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 26 Mar 2014 16:28:31 -0400

> Some drivers incorrectly assign vlan acceleration features to
> vlan_features thus causing issues for Q-in-Q vlan configurations.
> Prevent this once and for all by masking off acceleration features
> for vlan devices until such time as we support stacked acceleration.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

So what if we do have chips that can offload Q-in-Q?  Will we use
a new flag?
