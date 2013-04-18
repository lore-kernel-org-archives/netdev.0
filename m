From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/2] ixgbe: Fix a bug in setting VF VLAN via PF
Date: Thu, 18 Apr 2013 14:52:57 -0400 (EDT)
Message-ID: <20130418.145257.179706081574088947.davem@davemloft.net>
References: <1366267295-18420-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3DRSw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:52:59 -0400
In-Reply-To: <1366267295-18420-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 17 Apr 2013 23:41:35 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The PF driver does not check if the administrator has already set a VF
> VLAN via the PF driver before setting the new VLAN.  This results in
> the following scenario:
> 
> A) Administrator sets VF <n> to VLAN 100
> B) Administrator sets VF <x> to VLAN 100
> C) Administrator sets VF <n> to VLAN 200
> D) The VF <n> driver continues to be able to receive traffic on VLAN
>    100 because the VLVFB pool enable bit for that VF was left set
>    instead of being cleared as it should be.
> 
> This fix ensures that the old VLAN filter for VF <n> is first removed
> and the pool bit enable for VF <n> is cleared so that it no longer
> receives traffic on VLAN 100.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
