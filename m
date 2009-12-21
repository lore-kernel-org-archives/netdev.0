From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Mon, 21 Dec 2009 04:03:06 -0800 (PST)
Message-ID: <alpine.DEB.2.01.0912210352200.3483@bogon.housecafe.de>
References: <20091219111206.GA5307@wrars-comp.wrarsdomain> <20091220200343.GA5427@wrars-comp.wrarsdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>, Roger Luethi <rl@hellgate.ch>,
	netdev@vger.kernel.org
To: Andrey Rahmatullin <wrar@altlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:64525 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbZLUMDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 07:03:12 -0500
In-Reply-To: <20091220200343.GA5427@wrars-comp.wrarsdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[netdev Cc'ed]

On Mon, 21 Dec 2009 at 01:03, Andrey Rahmatullin wrote:
> Here are the proper screenshots from 2.6.33-rc1:
> http://wrar.name/temp/P1010724.JPG
> http://wrar.name/temp/P1010725.JPG

Wow, I had to rotate my laptop here. In you first posting [0] you said you 
"upgraded to .32" but had crashes in .30 too. What was the last working 
kernel?

In the .jpgs one can see something along the lines of 
schedule_timeout, napi_disable, rhine_tx_timeout - the only patch I could 
find touching these things [1] altogether is rather old, from 2.6.24. Is 
2.6.29 working for you? 

Christian.

[0] http://lkml.org/lkml/2009/12/19/36
[1] http://lists.openwall.net/netdev/2007/08/28/13
-- 
BOFH excuse #19:

floating point processor overflow
