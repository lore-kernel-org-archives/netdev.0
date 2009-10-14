From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [Patch-next] Fix the size overflow of addrconf_sysctl array
Date: Wed, 14 Oct 2009 21:14:48 +0300
Message-ID: <200910142114.53845.opurdila@ixiacom.com>
References: <4ACEA207.7010208@np.css.fujitsu.com> <200910091611.14701.cratiu@ixiacom.com> <20091013.034509.130893738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: cratiu@ixiacom.com, jin.dongming@np.css.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, seto.hidetoshi@jp.fujitsu.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27033 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755660AbZJNSSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 14:18:43 -0400
In-Reply-To: <20091013.034509.130893738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 October 2009 13:45:09 you wrote:
> From: Cosmin Ratiu <cratiu@ixiacom.com>
> Date: Fri, 9 Oct 2009 16:11:14 +0300
> 
> > Shouldn't this be changed too then?
> >
> > Or better yet, wouldn't a change that eliminates the need of adding a new
> > option in two separate places be useful?
> 
> Yes, it's crummy how things work now, indeed.
> 
> > I see the only use for that DEVCONF enum is to dump the settings via
> > netlink. Wouldn't a memcpy suffice?
> 
> It should be.
> 

I've taken a look at this and it seems the current way of doing it is really 
required as we need to preserve userspace ABI across different CONFIG_ 
settings.

tavi
