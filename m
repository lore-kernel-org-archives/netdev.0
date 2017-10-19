From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver
 Updates 2017-10-17
Date: Thu, 19 Oct 2017 11:50:14 +0100 (WEST)
Message-ID: <20171019.115014.1682502983666455223.davem@davemloft.net>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751897AbdJSKuc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 06:50:32 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 17 Oct 2017 11:21:04 -0700

> This series contains updates to i40e and ethtool.
> 
> Alan provides most of the changes in this series which are mainly fixes
> and cleanups.  Renamed the ethtool "cmd" variable to "ks", since the new
> ethtool API passes us ksettings structs instead of command structs.
> Cleaned up an ifdef that was not accomplishing anything.  Added function
> header comments to provide better documentation.  Fixed two issues in
> i40e_get_link_ksettings(), by calling
> ethtool_link_ksettings_zero_link_mode() to ensure the advertising and
> link masks are cleared before we start setting bits.  Cleaned up and fixed
> code comments which were incorrect.  Separated the setting of autoneg in
> i40e_phy_types_to_ethtool() into its own conditional to clarify what PHYs
> support and advertise autoneg, and makes it easier to add new PHY types in
> the future.  Added ethtool functionality to intersect two link masks
> together to find the common ground between them.  Overhauled i40e to
> ensure that the new ethtool API macros are being used, instead of the
> old ones.  Fixed the usage of unsigned 64-bit division which is not
> supported on all architectures.
> 
> Sudheer adds support for 25G Active Optical Cables (AOC) and Active Copper
> Cables (ACC) PHY types.

Pulled, thanks Jeff.
