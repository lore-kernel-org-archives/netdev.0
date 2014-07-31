From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 06/15] i40e: Move some variable declarations out of
 a loop
Date: Thu, 31 Jul 2014 14:05:59 -0700 (PDT)
Message-ID: <20140731.140559.2090702986159656213.davem@davemloft.net>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
	<1406766731-4209-7-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akeem.g.abodunrin@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbaGaVGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 17:06:02 -0400
In-Reply-To: <1406766731-4209-7-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Wed, 30 Jul 2014 17:32:02 -0700

> From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> 
> Declare some variables once outside of the loop instead of in
> every iteration of the loop.
> 
> Change-ID: I436913777c7da3c16dc0031b59e3ffa61de74718
> Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>

Why?  Decreasing the scope of variables makes the code easier to
understand and audit.

Now that it's declared at the top level people have to check whether
is it initialized properly in all possible code paths, in the entire
function, rather than just inside of the loop.

Please respin this series with this patch removed, thanks.
