From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] bonding: vlan handling changes
Date: Thu, 08 Aug 2013 22:32:07 -0700 (PDT)
Message-ID: <20130808.223207.1602322401343919999.davem@davemloft.net>
References: <1375785616-5349-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934295Ab3HIFcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 01:32:09 -0400
In-Reply-To: <1375785616-5349-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue,  6 Aug 2013 12:40:14 +0200

> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
> 
> Hi,
> In v2 of these patchset I've dropped the previous patch 01 (vlan 0 fix)
> because it'll be taken care of later and these two patches are not
> dependent on it.
> 
> Patch 01 - switches the bonding to the now standard vlan syncing functions
> vlan_vids_add/del_by_dev() and removes the bonding specific ones. In v2
> upon vlan addition failure we fail the enslavement with an error message
> because otherwise we might delete vlans that weren't added by the bonding.
> The only way this may happen is with ENOMEM currently, so we're in trouble
> anyway.
> 
> Patch 02 - reverts vlan addition in case of bond_add_vlan failure because
> otherwise we may get bad vlan refcounts in the slaves.
> This patch is queued for net-next because a fix for -net without the list
> conversion would mean taking care of special cases and would be really
> ugly. Since this bug is not critical, I'd rather have the fix for net-next.
> It can happen only with ENOMEM, so again we're already in trouble.
> 
> Patches 01 and 02 are not connected and if you decide to drop patch 02
> please leave 01 (if accepted).
> 
> v2: See the notes, I've explained the changes together and by patch.

Series applied, thanks.
