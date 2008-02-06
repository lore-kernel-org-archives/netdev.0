From: David Miller <davem@davemloft.net>
Subject: Re: [patch 14/14] replace __inline__ by inline in include/linux
 (net related)
Date: Wed, 06 Feb 2008 03:25:43 -0800 (PST)
Message-ID: <20080206.032543.30859566.davem@davemloft.net>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
	<20080206092300.701741592@mai.toulouse-stg.fr.ibm.com>
	<20080206.213100.60768610.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753487AbYBFLZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 06:25:14 -0500
In-Reply-To: <20080206.213100.60768610.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 06 Feb 2008 21:31:00 +1100 (EST)

> In article <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com> (at Wed, 06 Feb 2008 10:14:19 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:
> 
> > replace __inline__ by inline in include/linux (net related)
> > 
> > Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> > ---
> >  include/linux/atm.h        |    4 ++--
> >  include/linux/atmsap.h     |    2 +-
> >  include/linux/hdlc.h       |   13 +++++++------
> >  include/linux/inetdevice.h |   14 ++++++--------
> >  include/linux/netlink.h    |    5 +++--
> >  include/linux/rtnetlink.h  |    2 +-
> >  6 files changed, 20 insertions(+), 20 deletions(-)
> 
> Please do this change within the #ifdef __KERNEL__ .. #endif only.

What is the harm in fixing the user exposable portions?

There is exactly zero risk as far as I can see.
