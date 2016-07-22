From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: Re:  BUG: Wrong dma queue handling in ixp4 driver
Date: Fri, 22 Jul 2016 13:10:37 +0200
Message-ID: <trinity-476a1417-ff29-42b6-8e14-6470cfbb788b-1469185837787@3capp-gmx-bs80>
References: <trinity-275fae16-c9c8-4503-85fe-5585fb014c7a-1468926357992@3capp-gmx-bs21>
 <trinity-28228d79-2b64-4d9c-89c2-6ce288a8ed49-1468927909503@3capp-gmx-bs21>,
 <m3lh0urnc4.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=22Krzysztof_Ha=C5=82asa=22?= <khalasa@piap.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:55099 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329AbcGVLKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 07:10:40 -0400
In-Reply-To: <m3lh0urnc4.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Krzysztof,

> 
> Not really: there is one pool for all ports, but each port uses
> a separate desc_tab (allocated from that pool).

right, but even then using a dma pool seems to be a bit of overhead
for only a few allocations. As far as I understood those pools are 
meant for hundrets or thousands of rather small chunks.
 
I dont want to criticise it though, since the code at this place is surely
 not wrong. 
My initial post was due to a misunderstanding of mine: I thought the 
third parameter of dma_pool_create() is the total allocation size of all
chunks (dont ask me how I came to this conclusion, I could not explain it now :/ ).

Regards,
Lino
