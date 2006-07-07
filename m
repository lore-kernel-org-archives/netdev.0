From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Sat, 08 Jul 2006 01:48:13 +0900 (JST)
Message-ID: <20060708.014813.119417005.yoshfuji@linux-ipv6.org>
References: <20060630150823.A22285@castle.nmd.msu.ru>
	<20060707.133434.125915077.yoshfuji@linux-ipv6.org>
	<20060707115425.A28991@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvz.org, ebiederm@xmission.com,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:24337 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932218AbWGGQrH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 12:47:07 -0400
To: saw@swsoft.com
In-Reply-To: <20060707115425.A28991@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060707115425.A28991@castle.nmd.msu.ru> (at Fri, 7 Jul 2006 11:54:25 +0400), Andrey Savochkin <saw@swsoft.com> says:

> On Fri, Jul 07, 2006 at 01:34:34PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> > In article <20060630150823.A22285@castle.nmd.msu.ru> (at Mon, 3 Jul 2006 12:18:51 +0400), Andrey Savochkin <saw@swsoft.com> says:
> > 
> > > @@ -3271,22 +3277,22 @@ int unregister_netdevice(struct net_devi
> > >  
> > >  	/* And unlink it from device chain. */
> > >  	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
> > 
> > Why not for_each_netdev?
> 
> it's a different list

Sorry, I still do not understand.
In other words, why will we still have dev->next?
After introducing net_device->dev_list, we do not need
dev->next anymore, do we?

--yoshfuji

