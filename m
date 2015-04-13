From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
 2015-04-11
Date: Sun, 12 Apr 2015 21:47:12 -0400 (EDT)
Message-ID: <20150412.214712.1267122339439286016.davem@davemloft.net>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbDMBrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 21:47:14 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 11 Apr 2015 12:07:47 -0700

> This series contains updates to iflink, ixgbe and ixgbevf.
> 
> The entire set of changes come from Vlad Zolotarov to ultimately add
> the ethtool ops to VF driver to allow querying the RSS indirection table
> and RSS random key.
> 
> Currently we support only 82599 and x540 devices.  On those devices, VFs
> share the RSS redirection table and hash key with a PF.  Letting the VF
> query this information may introduce some security risks, therefore this
> feature will be disabled by default.
> 
> The new netdev op allows a system administrator to change the default
> behaviour with "ip link set" command.  The relevant iproute2 patch has
> already been sent and awaits for this series upstream.

Pulled, thanks Jeff.
