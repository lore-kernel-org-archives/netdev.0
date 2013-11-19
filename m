From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6 fragmentation-related panic in netfilter
Date: Tue, 19 Nov 2013 13:40:32 +0100
Message-ID: <20131119124032.GS16541@order.stressinduktion.org>
References: <2060a7d2-c307-4e30-b1d4-0bd26c904d6f@gmail.com> <20131101084529.GL31491@secunet.com> <20131101092536.GA17499@macbook.localnet> <19807032.ebUJct12DE@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Tomas Hlavacek <tmshlvck@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52392 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004Ab3KSMkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 07:40:33 -0500
Content-Disposition: inline
In-Reply-To: <19807032.ebUJct12DE@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 12:11:24PM +0100, Wolfgang Walter wrote:
> Are there patches available? I can crash my 3.12 kernel easily doing
> 
> 	fping -p 20 -l -b 4000 bla
> 
> 3.11.x does not expose this problem.

Yes, see here:

http://patchwork.ozlabs.org/patch/288967/
http://patchwork.ozlabs.org/patch/288970/

Greetings,

  Hannes
