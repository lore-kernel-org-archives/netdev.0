From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] vlan: Make it possible to add vlan with id 4095
Date: Mon, 12 Nov 2012 21:37:48 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1211122128300.24241@nerf07.vanv.qr>
References: <20120928123258.9454.95197.stgit@localhost.localdomain> <20120928.134417.1763308761361480629.davem@davemloft.net> <alpine.LNX.2.01.1211121941370.1611@nerf07.vanv.qr> <50A14781.1030106@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, paulius.zaleckas@gmail.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:53518 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab2KLUht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 15:37:49 -0500
In-Reply-To: <50A14781.1030106@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2012-11-12 20:01, Ben Greear wrote:
>>>
>>> Awesome, we don't need VXVLAN any more after this fix.
>>
>> You mean because the special 0xfff value could indicate "here's more
>> headers"? Sounds like a plan.
>
> You can't just use reserved values...

Indeed not; I was just implicitly thinking of the 802.1Q standard
comittee getting an impetus from the public disgust against VXVLAN to
define 0xfff with extensions that allow for e.g. stacking, making
VXVLAN redundant and obsolete. :)
