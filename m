From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: softmac mtu
Date: Sat, 23 Sep 2006 16:40:15 -0500
Message-ID: <4515A9BF.90709@lwfinger.net>
References: <ef3s4u$or5$3@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:64473 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750726AbWIWVkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 17:40:17 -0400
To: Matthieu CASTET <castet.matthieu@free.fr>
In-Reply-To: <ef3s4u$or5$3@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthieu CASTET wrote:
> Hi,
> 
> why softmac (and maybe device using linux 80211 stack) can't increase
> their mtu above 1500 ?
> 
> IRRC 802.11 allow to send bigger frame. Moreover some driver like airo
> allow to use mtu biger than 2000.

The maximum value for MTU is set in include/linux/if_ether.h for all ethernet-type communications, 
not in softmac or ieee80211. I doubt that one could easily change the number. It may be that the 
802.11 standard allows bigger frames, but it looks to me as if Linux does not.

Larry
