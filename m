From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: implement auto-loading of generic netlink
 modules
Date: Tue, 29 May 2012 22:34:34 -0400 (EDT)
Message-ID: <20120529.223434.508811240180990047.davem@davemloft.net>
References: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	jchapman@katalix.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756279Ab2E3Cfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 22:35:48 -0400
In-Reply-To: <1338319842-18395-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 29 May 2012 15:30:39 -0400

> 
> Eric D. recently noted that the drop_monitor module didn't autoload when the
> dropwatch user space utility started.  Looking into this I noted that theres no
> formal macro set to define module aliases that can be used by a request module
> call in the generic netlink family lookup path.  Currenlty the
> net-pf-*-proto-*-type-<n> format is used, but the macros which form this expect
> <n> to be a well defined integer, which generic netlink doesn't use for family
> definitions.  So this series creates a new macro that create a
> net-pf-*-proto-*-name format where name can be any arbitrary string, allowing us
> to apend family-<x> where x is a generic netlink family name.  With these
> macros, we can easily autoload modules that register generic netlink families
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Looks great, all applied, thanks Neil.
