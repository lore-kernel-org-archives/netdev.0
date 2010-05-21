From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net-2.6 : V2 - fix dev_get_valid_name
Date: Fri, 21 May 2010 16:25:06 +0300
Message-ID: <201005211625.06234.opurdila@ixiacom.com>
References: <1274299939-28132-1-git-send-email-daniel.lezcano@free.fr> <4BF68635.4070202@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12879 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752896Ab0EUNZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 09:25:09 -0400
In-Reply-To: <4BF68635.4070202@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 21 May 2010 16:10:13 you wrote:
> On 05/19/2010 10:12 PM, Daniel Lezcano wrote:
> > the commit:
> >
> > commit d90310243fd750240755e217c5faa13e24f41536
> > Author: Octavian Purdila<opurdila@ixiacom.com>
> > Date:   Wed Nov 18 02:36:59 2009 +0000
> >
> >      net: device name allocation cleanups
> >
> > introduced a bug when there is a hash collision making impossible
> > to rename a device with eth%d. This bug is very hard to reproduce
> > and appears rarely.
> >
> > The problem is coming from we don't pass a temporary buffer to
> > __dev_alloc_name but 'dev->name' which is modified by the function.
> >
> > A detailed explanation is here:
> >
> > http://marc.info/?l=linux-netdev&m=127417784011987&w=2
> >
> > Changelog:
> >   V2 : replaced strings comparison by pointers comparison
> >
> > Signed-off-by: Daniel Lezcano<daniel.lezcano@free.fr>
> > ---
> 
> Octavian, are you ok with this patch ?
> 

Yes, all looks good to me, thanks for the fix.

Reviewed-by: Octavian Purdila <opurdila@ixiacom.com>

