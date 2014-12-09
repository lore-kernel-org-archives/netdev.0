From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/13][pull request] Intel Wired LAN Driver
 Updates 2014-12-09
Date: Tue, 09 Dec 2014 17:01:40 -0500 (EST)
Message-ID: <20141209.170140.407473993796162678.davem@davemloft.net>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaLIWBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 17:01:44 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  9 Dec 2014 13:26:07 -0800

> This series contains updates to i40e and i40evf.
> 
> Jeff (me) provides a single patch to convert a macro to a static inline
> function based on feedback from Joe Perches on a previous patch.
> 
> Shannon provides the remaining twelve patches against i40e.  Almost all
> of Shannon's patches cleanup/fix NVM issues varying in range from
> adding more detail to debug messages, to removing dead code, to fixing
> NVM state transitions after an error.  Change the handy decoder interface
> for admin queue return code to help catch and properly report the condition
> as a useful errno rather than returning a misleading '0'.  Added a range
> check to avoid any possible array index-out-of-bound issues.
> 
> v2:
>  - fixed up patch 05 in the series to use the ARRAY_SIZE() macro as suggested
>    by Sergei Shtylyov
>  - fix up patch 13 to remove unnecessary parens in the return statement
>    as suggested by Sergei Shtylyov

Pulled, thanks for the quick turnaround Jeff.
