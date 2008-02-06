From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch 14/14] replace __inline__ by inline in include/linux
 (net related)
Date: Wed, 06 Feb 2008 21:31:00 +1100 (EST)
Message-ID: <20080206.213100.60768610.yoshfuji@linux-ipv6.org>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
	<20080206092300.701741592@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44138 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbYBFKa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 05:30:26 -0500
In-Reply-To: <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com> (at Wed, 06 Feb 2008 10:14:19 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:

> replace __inline__ by inline in include/linux (net related)
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> ---
>  include/linux/atm.h        |    4 ++--
>  include/linux/atmsap.h     |    2 +-
>  include/linux/hdlc.h       |   13 +++++++------
>  include/linux/inetdevice.h |   14 ++++++--------
>  include/linux/netlink.h    |    5 +++--
>  include/linux/rtnetlink.h  |    2 +-
>  6 files changed, 20 insertions(+), 20 deletions(-)

Please do this change within the #ifdef __KERNEL__ .. #endif only.

--yoshfuji
