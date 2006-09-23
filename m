From: David Miller <davem@davemloft.net>
Subject: Re: softmac mtu
Date: Sat, 23 Sep 2006 14:47:57 -0700 (PDT)
Message-ID: <20060923.144757.78710420.davem@davemloft.net>
References: <ef3s4u$or5$3@sea.gmane.org>
	<4515A9BF.90709@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: castet.matthieu@free.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:936
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750731AbWIWVr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 17:47:58 -0400
To: Larry.Finger@lwfinger.net
In-Reply-To: <4515A9BF.90709@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Sat, 23 Sep 2006 16:40:15 -0500

> The maximum value for MTU is set in include/linux/if_ether.h for all
> ethernet-type communications, not in softmac or ieee80211. I doubt
> that one could easily change the number. It may be that the 802.11
> standard allows bigger frames, but it looks to me as if Linux does
> not.


Not correct.  Linux is perfectly fine with setting 9000 byte MTU on
ethernet devices that support it, and in fact just about every
gigabit ethernet driver supports it.

That macro you see in if_ether.h is just the value of the base MTU
limit, so larger MTU settings are easily allowable on a per-device
basis.
