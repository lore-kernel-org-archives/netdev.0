From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] macvlan: Support creating macvtaps from macvlans
Date: Thu, 05 Dec 2013 19:59:33 -0500 (EST)
Message-ID: <20131205.195933.1470416409498837252.davem@davemloft.net>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
	<1386068122-12039-1-git-send-email-kevin@pentabarf.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkubecek@suse.cz
To: kevin@pentabarf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3LFA7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 19:59:34 -0500
In-Reply-To: <1386068122-12039-1-git-send-email-kevin@pentabarf.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Wallace <kevin@pentabarf.net>
Date: Tue,  3 Dec 2013 02:55:22 -0800

> When running in a network namespace whose only link to the outside
> world is a macvlan device, not being able to create a macvtap off of
> it is a real pain.
> 
> So modify macvtap creation to automatically forward a creation of a
> macvtap on a macvlan to become a creation of a macvtap on the
> underlying network device, just like is currently done with
> macvlan-on-macvlan devices.
> 
> v2: Use netif_is_macvlan and macvlan_dev_real_dev helpers to make it
>     more clear what we're doing.
> 
> Signed-off-by: Kevin Wallace <kevin@pentabarf.net>

Applied to net-next, thanks.
