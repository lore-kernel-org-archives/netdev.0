From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6 v3][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Oct 2011 20:22:18 -0400 (EDT)
Message-ID: <20111017.202218.353019756731902662.davem@davemloft.net>
References: <1318896767-5374-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<4E9CC52C.6030902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com, tarbal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab1JRAW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 20:22:27 -0400
In-Reply-To: <4E9CC52C.6030902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <tarbal@gmail.com>
Date: Mon, 17 Oct 2011 17:15:40 -0700

> On 10/17/2011 05:12 PM, Jeff Kirsher wrote:
>> The following series contains updates to ixgbe, igbvf and igb.
>> This version of the series contains the following changes:
>>
>> - igb fix/add check if subordinate VFs are assigned to VM's
>> - igbvf fix for trunk VLAN
>> - ixgbe 2 fixes for ethtool and 1 endianess fix
>>
>> -v2 update the igb patch to resolve a variable initialization warning
>> -v3 Drop patch 5 (ixgbe: add hardware time stamping support)
>>
>> The following are changes since commit fd38f734cb8200529e281338514945fcbff2364b:
>>   igbvf: convert to ndo_fix_features
>> and are available in the git repository at
>>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
>>
>> Emil Tantilov (3):
>>   ixgbe: fix endianess when writing driver version to firmware
>>   ixgbe: allow eeprom writes via ethtool
>>   ixgbe: change the eeprom version reported by ethtool
>>
>> Greg Rose (2):
>>   igbvf: Fix trunk vlan
>>   igb: Check if subordinate VFs are assigned to virtual machines
>>
>>  drivers/net/ethernet/intel/igb/igb.h             |    3 +
>>  drivers/net/ethernet/intel/igb/igb_main.c        |  177 ++++++++++++++++++----
>>  drivers/net/ethernet/intel/igbvf/netdev.c        |    4 +-
>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 +-
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |    2 +
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   16 +-
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   84 ++++++++++-
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    7 +-
>>  8 files changed, 246 insertions(+), 50 deletions(-)
>>
> Grrr, forgot to update the title of the cover page.  It *should* be
> "net-next 0/5 v3]..."

No worries, pulled, thanks Jeff!
