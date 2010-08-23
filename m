From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 0/6] be2net: some bug fixes for net-2.6
Date: Sun, 22 Aug 2010 18:54:11 -0700 (PDT)
Message-ID: <20100822.185411.70202273.davem@davemloft.net>
References: <20100822092928.GA22387@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49902
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751290Ab0HWBxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 21:53:55 -0400
In-Reply-To: <20100822092928.GA22387@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Sun, 22 Aug 2010 14:59:37 +0530

> Patchset includes bug fixes for net-2.6. Please apply.
> 
> 1/5: fix net-snmp error because of wrong packet stats
> 2/6: fix a bug in UE detection logic
> 3/6: remove a BUG_ON in be_cmds.c
> 4/6: fix to dynamically generate MAC Address for VFs
> 5/6: display statistics for packets received due to internal switching in ASIC.
> 6/6: fix to get RxQ IDs 0 and 1.

These are not regression fixes.

Especially the patch which adds stats counting for packets internally
switched inside of the ASIC.

Seperate out the real regression fixes for 2.6.36 and post those for
net-2.6  Everything else must go to net-next-2.6

Thank you.
