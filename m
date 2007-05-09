From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] ROUTE: Assign rt6i_idev for
 ip6_{prohibit,blk_hole}_entry.
Date: Wed, 09 May 2007 17:42:28 +0900 (JST)
Message-ID: <20070509.174228.18186896.yoshfuji@linux-ipv6.org>
References: <20070509.170550.81965404.yoshfuji@linux-ipv6.org>
	<20070509.011333.122833121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37417 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbXEIImO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 04:42:14 -0400
In-Reply-To: <20070509.011333.122833121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070509.011333.122833121.davem@davemloft.net> (at Wed, 09 May 2007 01:13:33 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Wed, 09 May 2007 17:05:50 +0900 (JST)
> 
> > We need to assign rt6i_idev for ip6_{prohibit,blk_hole}_entry as well
> > as we are doing for ip6_null_entry.
> > 
> > 2.6.20-stable also needs this.
> > 
> > Closes: Bug#8450
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Applied, and I'll push to -stable, thanks.

Wait for a moment, please.
I thought it should fix the issue, but
I must say, the fix does not seem sufficient...

I'm now analysing further.

--yoshfuji

