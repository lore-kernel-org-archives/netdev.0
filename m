From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: linux-next: net build failure
Date: Thu, 27 Mar 2008 21:12:34 +0900 (JST)
Message-ID: <20080327.211234.18526256.yoshfuji@linux-ipv6.org>
References: <20080327.022206.100283150.davem@davemloft.net>
	<20080327.193006.132922343.yoshfuji@linux-ipv6.org>
	<20080327.040502.144245837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55338 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275AbYC0MLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:11:08 -0400
In-Reply-To: <20080327.040502.144245837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080327.040502.144245837.davem@davemloft.net> (at Thu, 27 Mar 2008 04:05:02 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Thu, 27 Mar 2008 19:30:06 +0900 (JST)
> 
> > How about this?
> > I believe all functions are not used outside the net subsystem.
> > 
> > I'm still testing with allmodconfig but 
> > at least, allnoconfig works for me.
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Denis has posted a slightly different approach.
> 
> I kind of agree with what he is doing, because kobject_uevent
> should not be including any networking headers when CONFIG_NET
> is not set and that causes large portions of the breakage.
> 
> What do you think of his 2 patches?

I agree.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
