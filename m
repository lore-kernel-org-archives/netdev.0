From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] vhost-net: fix handle_rx buffer size
Date: Fri, 11 May 2012 18:17:43 -0400 (EDT)
Message-ID: <20120511.181743.1666617052592850607.davem@davemloft.net>
References: <1336121724-31902-1-git-send-email-basil.gor@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: basil.gor@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266Ab2EKWRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:17:48 -0400
In-Reply-To: <1336121724-31902-1-git-send-email-basil.gor@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Basil Gor <basil.gor@gmail.com>
Date: Fri,  4 May 2012 12:55:23 +0400

> Take vlan header length into account, when vlan id is stored as
> vlan_tci. Otherwise tagged packets comming from macvtap will be
> truncated.
> 
> Signed-off-by: Basil Gor <basil.gor@gmail.com>

My patience with Eric B. to review this has run out, applied,
thanks Basil.
