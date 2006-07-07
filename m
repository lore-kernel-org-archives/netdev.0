From: Andrey Savochkin <saw@swsoft.com>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Fri, 7 Jul 2006 11:54:25 +0400
Message-ID: <20060707115425.A28991@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru> <20060707.133434.125915077.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvz.org, ebiederm@xmission.com,
	kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:7946 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1750957AbWGGHy2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 03:54:28 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?\(B" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20060707.133434.125915077.yoshfuji@linux-ipv6.org>; from "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" on Fri, Jul 07, 2006 at 01:34:34PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 01:34:34PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> In article <20060630150823.A22285@castle.nmd.msu.ru> (at Mon, 3 Jul 2006 12:18:51 +0400), Andrey Savochkin <saw@swsoft.com> says:
> 
> > @@ -3271,22 +3277,22 @@ int unregister_netdevice(struct net_devi
> >  
> >  	/* And unlink it from device chain. */
> >  	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
> 
> Why not for_each_netdev?

it's a different list
