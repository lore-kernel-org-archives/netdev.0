From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix kernel crash and EEH recovery issues
Date: Sat, 24 May 2014 00:21:21 -0400 (EDT)
Message-ID: <20140524.002121.2074918078161112353.davem@davemloft.net>
References: <20140523162955.780765614@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wenxiong@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbaEXEVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 00:21:23 -0400
In-Reply-To: <20140523162955.780765614@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wenxiong@linux.vnet.ibm.com
Date: Fri, 23 May 2014 11:29:55 -0500

> The patches fix kernel crash and EEH recovery issues.

Can you please have some courtesy and CC: the maintainers
of this driver when you submit fixes to it?

Also, all of that detailed explaination you put into patch #2
belongs also in a comment about the memory barrier in the code.

Every memory barrier should be clearly explained with a comment
especially when a non-SMP barrier is involved.
