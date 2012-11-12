From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] vlan: Make it possible to add vlan with id 4095
Date: Mon, 12 Nov 2012 19:42:12 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1211121941370.1611@nerf07.vanv.qr>
References: <20120928123258.9454.95197.stgit@localhost.localdomain> <20120928.134417.1763308761361480629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paulius.zaleckas@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:53238 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab2KLSmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 13:42:13 -0500
In-Reply-To: <20120928.134417.1763308761361480629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 2012-09-28 19:44, David Miller wrote:

>From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
>Date: Fri, 28 Sep 2012 15:32:58 +0300
>
>> vconfig help tells that vlan_id should be 0-4095, but fails
>> with 4095.
>> 
>> There is an off-by-one bug while evaluating vlan_id.
>> Fix it by evaluating against count(4096), not mask(0x0fff = 4095).
>> 
>> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
>
>Awesome, we don't need VXVLAN any more after this fix.

You mean because the special 0xfff value could indicate "here's more 
headers"? Sounds like a plan.
