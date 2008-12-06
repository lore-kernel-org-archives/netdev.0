From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] staging-p80211: Kill directly reference of c
Date: Fri, 05 Dec 2008 18:30:15 -0800 (PST)
Message-ID: <20081205.183015.127189402.davem@davemloft.net>
References: <4939456D.8010003@cn.fujitsu.com>
	<20081205154446.GB28030@suse.de>
	<4939E35D.4010102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754069AbYLFCaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 21:30:15 -0500
In-Reply-To: <4939E35D.4010102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Sat, 06 Dec 2008 10:28:45 +0800

> Greg KH said the following on 2008-12-5 23:44:
> > thanks for the patch, I'll queue it up,
> 
> I'm doing this "kill netdev->priv" work on Dave's net-next tree now.
> So, will it be better to let Dave apply this to his net-next instead
> you apply it?
> Just suggestion :)

Yes, I would prefer it be done this way so I can do the final
kill of the netdev->priv member without having to wait for
a dependency on the staging tree :)
