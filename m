From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ehea: fix allmulticast support
Date: Thu, 26 Apr 2012 05:08:13 -0400 (EDT)
Message-ID: <20120426.050813.912346367190277632.davem@davemloft.net>
References: <1335375132-4591-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58064 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936Ab2DZJIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:08:17 -0400
In-Reply-To: <1335375132-4591-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Wed, 25 Apr 2012 14:32:11 -0300

> There was a bug in the mask of regtype parameter for registering a
> multicast filter. It was ignoring the scope bit, which was wrongly being
> used for all filters. The SCOPE_ALL value adds a filter that allows all
> multicast packets and ignores the MAC parameter, just what allmulticast
> needs. The normals filters, however, should not use SCOPE_ALL.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied.
