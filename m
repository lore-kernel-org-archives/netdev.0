From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux v3 net-next 0/5] add netlink support for new lacp
 bonding parameters
Date: Mon, 11 May 2015 11:00:04 -0400 (EDT)
Message-ID: <20150511.110004.649964826481502303.davem@davemloft.net>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, shm@cumulusnetworks.com,
	razor@blackwall.org
To: jtoppins@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbEKPAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:00:07 -0400
In-Reply-To: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Date: Sat,  9 May 2015 00:01:54 -0700

> This is a resubmit of Mahesh's last 3 bonding patches from this series
> (http://marc.info/?l=linux-netdev&m=142432864626179&w=2) with one
> additional kernel patch which adds the netlink bits. I have noted any
> modifications I did to the original patches just above my signoff line.
> Patch 5 is the iproute2 support for these bonding options. All patches
> were coded against the net-next branch of their respective projects.
> 
> v2:
>   * rebased
>   * only send these new parameters via netlink when bond is in mode 4
>   * fixed ad_actor_sys_prio to be 0xFFFF by default even when the bond
>     is initially created in mode 0 and switched to mode 4
> 
> v3:
>   * reverted changes to bond_option_ad_actor_system_set() from v1 in Mahesh's
>     patch "bonding: Allow userspace to set actors' macaddr in an AD-system."
>     Instead implementing all setting in the option specific set function as
>     Nik suggested.

Series applied, thanks.

There are actually 4 patches in this series, so this subject should have
said "0/4" instead of "0/5" :-)
