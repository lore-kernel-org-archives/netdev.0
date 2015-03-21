From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
 2015-03-20
Date: Fri, 20 Mar 2015 21:41:02 -0400 (EDT)
Message-ID: <20150320.214102.118150337215691503.davem@davemloft.net>
References: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbbCUBlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 21:41:04 -0400
In-Reply-To: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Mar 2015 17:57:40 -0700

> This series contains updates to ixgb, e1000e, igb and igbvf.
> 
> Eliezer and Todd provide patches to fix a potential issue found during code
> inspection.  When bringing down an interface netif_carrier_off() should
> be one of the first things we do, since this will prevent the stack from
> queueing more packets to this interface.
> 
> Yanir provides a fix for e1000e that was found in validating i219,
> where the call to e1000e_write_protect_nvm_ich8lan() is no longer
> supported in newer hardware.  Access to these registers causes a
> system freeze in early steppings and is ignored in later steppings.

Looks good, pulled, thanks Jeff.
