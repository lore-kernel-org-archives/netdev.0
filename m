From: David Miller <davem@davemloft.net>
Subject: Re: [patch 14/14] replace __inline__ by inline in include/linux
 (net related)
Date: Wed, 06 Feb 2008 03:27:09 -0800 (PST)
Message-ID: <20080206.032709.166069933.davem@davemloft.net>
References: <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com>
	<20080206.213100.60768610.yoshfuji@linux-ipv6.org>
	<47A98E5F.7010207@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753781AbYBFL0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 06:26:39 -0500
In-Reply-To: <47A98E5F.7010207@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 06 Feb 2008 11:39:27 +0100

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com> (at Wed, 06 Feb 2008 10:14:19 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:
> > 
> >> replace __inline__ by inline in include/linux (net related)
> >>
> >> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> >> ---
> >>  include/linux/atm.h        |    4 ++--
> >>  include/linux/atmsap.h     |    2 +-
> >>  include/linux/hdlc.h       |   13 +++++++------
> >>  include/linux/inetdevice.h |   14 ++++++--------
> >>  include/linux/netlink.h    |    5 +++--
> >>  include/linux/rtnetlink.h  |    2 +-
> >>  6 files changed, 20 insertions(+), 20 deletions(-)
> > 
> > Please do this change within the #ifdef __KERNEL__ .. #endif only.
> 
> Oups ! I didn't thought about userspace program when modifying these 
> headers. Thanks for catching this.
> 
> Hopefully, the patches can be applied separately. Is it possible to 
> discard this one ?

What is the real problem though?

Oh, c89 style C compilation will break with plain "inline"?

