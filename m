From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 06/15] i40e: Move some variable declarations out of
 a loop
Date: Thu, 31 Jul 2014 18:31:09 -0700 (PDT)
Message-ID: <20140731.183109.742589264674095169.davem@davemloft.net>
References: <1406766731-4209-7-git-send-email-aaron.f.brown@intel.com>
	<20140731.140559.2090702986159656213.davem@davemloft.net>
	<CFEEE81102D91947B9CC368106979EBA479BEBE6@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aaron.f.brown@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: akeem.g.abodunrin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbaHABbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 21:31:12 -0400
In-Reply-To: <CFEEE81102D91947B9CC368106979EBA479BEBE6@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Abodunrin, Akeem G" <akeem.g.abodunrin@intel.com>
Date: Thu, 31 Jul 2014 23:56:19 +0000

> This is done because other codes have to use it before the loop...
> 
> Hope you understand the reason for this - and that is how it supposed to be originally, we have to increase the scope of the variables so that other code that are not in the loop can use it.

What codes?  I looked at the patches after this one and none of them use
the variables.

If anything you should make this change in the patch that needs it, not
beforehand.
