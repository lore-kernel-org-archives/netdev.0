From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Wed, 22 May 2013 13:57:25 -0700 (PDT)
Message-ID: <20130522.135725.2055012330878292564.davem@davemloft.net>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756851Ab3EVU52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 16:57:28 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 21 May 2013 15:03:08 -0700

> This series contains updates to e1000e, igb and ixgbe.
> 
> Bruce Allan provide 2 minor cleanups for e1000e to resolve whitespace
> issues and build warnings about unused parameters.
> 
> Carolyn provides a couple of fixes for igb, one being a fix for a
> possible panic when the interface is down and receive traffic
> arrives.  The second fix resolves an issue on newer parts which have
> multiple checksum fields and set_ethtool was only checking to update
> the first checksum of the NVM image.
> 
> Akeem provides majority of the changes in this patch set.  Akeem
> provides a fix for e1000e on an issue reported from the community to
> resolve the issue of unlocking swflag_mutex for 82574 and 82583
> devices even if the hardware semaphore was successfully acquired.
> The other patches from Akeem are against igb, where he adds support
> SFP module discovery, LED blink mechanism for devices using cathodes,
> LED support for i210/i211 parts and cleanup of a i2c function which
> was not being used.
> 
> Matthew provides an update for igb to support a more accurate check
> for a PTP RX hang.
> 
> Amir provides a patch for ixgbe to set the software prio_tc values at
> initialization to the hardware setting to remove the need to reset the
> device at the first time we call ixgbe_dcbnl_ieee_setets.
> 
> The following are changes since commit 1e18583adccfc122b5d6415cfe4bf1826c370f4e:
>   ThunderLAN: remove is_eisa flag
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, excellent merge commit message, thanks!
