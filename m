From: David Miller <davem@davemloft.net>
Subject: Re: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 15:56:12 -0700 (PDT)
Message-ID: <20060815.155612.111203542.davem@davemloft.net>
References: <20060815214914.GA5307@nostromo.devel.redhat.com>
	<Pine.CYG.4.58.0608151532070.2316@mawilli1-desk2.amr.corp.intel.com>
	<20060815154444.286e12ed@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, notting@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28604
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750797AbWHOW5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 18:57:10 -0400
To: shemminger@osdl.org
In-Reply-To: <20060815154444.286e12ed@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 15 Aug 2006 15:44:44 -0700

> IMHO idiots who put space's in filenames should be ignored. As long
> as the bonding code doesn't throw a fatal error, it has every right
> to return "No such device" to the fool.

I agree that whitespace in device names push the limits of sanity.

But if we believe that, we should enforce it in dev_valid_name().

Does anyone really mind if I add the whitespace check there?
