From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 16:16:30 -0500 (EST)
Message-ID: <20120221.161630.1122203779408129070.davem@davemloft.net>
References: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab2BUVQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:16:46 -0500
In-Reply-To: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Greg, where is the code that guards the actual dumping of the VF
information based upon the ext mask?

I only see the ext mask controlling the sizing of the SKB.  What good
is that if we still dump the VFs?
