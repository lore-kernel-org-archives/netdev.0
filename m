From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next PATCH 0/6] i40e: Add VF port representator support
 or SR-IOV VFs
Date: Fri, 30 Dec 2016 08:55:05 -0800
Message-ID: <58669169.5050006@intel.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com> <20161229.215356.2143143534347167491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36289 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750968AbcL3QzI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 11:55:08 -0500
In-Reply-To: <20161229.215356.2143143534347167491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/2016 6:53 PM, David Miller wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Date: Thu, 29 Dec 2016 22:20:57 -0800
>
>> - Patch 1 introduces devlink interface to get/set the mode of SRIOV switch.
>> - Patch 2 adds support to create VF port representor(VFPR) netdevs associated
>>    with SR-IOV VFs that can be used to control/configure VFs from PF name space.
>> - Patch 3 enables syncing link state between VFs and VFPRs.
>> - Patch 4 adds a new type to metadata_dst to allow passing VF id to lower device.
>> - Patch 5 adds TX and RX support to VFPR netdevs.
>> - Patch 6 enables HW and SW VFPR statistics to be exposed via netlink on VFPR
>>    netdevs.
> Patch 4 did not show up on the lists.
I see it on intel-wired-lan list.  not sure why it didn't make it to netdev.
>
> The computer you did this work on is configured with a time in the future.
Will fix and send a v2 that will address other comments and include patch 4.
