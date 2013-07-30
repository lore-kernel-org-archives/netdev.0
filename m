From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 03/15] ixgbe: fix fc autoneg ethtool reporting.
Date: Mon, 29 Jul 2013 22:18:33 -0700 (PDT)
Message-ID: <20130729.221833.2091004041005201998.davem@davemloft.net>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1375102331-23905-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216Ab3G3FSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 01:18:34 -0400
In-Reply-To: <1375102331-23905-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 29 Jul 2013 05:51:59 -0700
> @@ -67,15 +67,39 @@ static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw);
>   **/
>  s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
>  {
> +	bool supported = false;
 ...
> +	return supported;

If the function is returning bool, fix the function's return type from
's32' to 'bool'.


> -		    (ixgbe_device_supports_autoneg_fc(hw) == 0)) {
> +		    (ixgbe_device_supports_autoneg_fc(hw))) {

I think the outermost parenthesis in "(ixgbe_device_supports_autoneg_fc(hw))"
should be removed.
