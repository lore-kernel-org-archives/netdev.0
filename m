From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
 2015-06-03
Date: Wed, 03 Jun 2015 20:20:43 -0700 (PDT)
Message-ID: <20150603.202043.743479212110876012.davem@davemloft.net>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbbFDDUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:20:44 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  3 Jun 2015 04:27:47 -0700

> This series contains updates to e1000e only.
> 
> Yanir provides 8 fixes and 1 version bump for e1000e.  First fix resolves
> a possible unit hang if multiple descriptors are available in the rings
> during reset or runtime suspend.  Fixed a warning on SPARC compile based
> on a suggested solution from Alex Duyck.  Fixed a logical error, where
> a "if" condition under which a flush should occur, was revered.  Fixed
> a hardware issue that prevented i219 from working in legacy interrupts
> mode.  Fixed the hardware clock configuration and suprious non-linear
> increment.  Lastly, fixed a system hang which occurred during execution
> of "ethtool -t <NIC>", by disabling MULR for the loopback test to avoid
> the hand state.

Pulled, thanks a lot Jeff.
