From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: net build failure
Date: Thu, 27 Mar 2008 02:22:06 -0700 (PDT)
Message-ID: <20080327.022206.100283150.davem@davemloft.net>
References: <20080327182441.8d09b8ad.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758653AbYC0JWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 05:22:06 -0400
In-Reply-To: <20080327182441.8d09b8ad.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 27 Mar 2008 18:24:41 +1100

> Today's linux-next build (powerpc allnoconfig (i.e. CONFIG_NET not
> defined)) fails thusly:
> 
> In file included from include/linux/rtc.h:112,
>                  from include/linux/efi.h:20,
>                  from init/main.c:44:
> include/linux/seq_file.h: In function 'seq_file_net':
> include/linux/seq_file.h:81: error: 'init_net' undeclared (first use in this function)
> include/linux/seq_file.h:81: error: (Each undeclared identifier is reported only once
> include/linux/seq_file.h:81: error: for each function it appears in.)
> 
> Introduced by commit 1218854afa6f659be90b748cf1bc7badee954a35 ("[NET]
> NETNS: Omit seq_net_private->net without CONFIG_NET_NS.").

Yoshifuji-san, please fix this.

I tried to, but the cases, especially those in netdevice.h, are
difficult to resolve.

Thank you.
