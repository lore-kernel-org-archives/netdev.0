From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] vlan: Make it possible to add vlan with id 4095
Date: Mon, 12 Nov 2012 11:01:21 -0800
Message-ID: <50A14781.1030106@candelatech.com>
References: <20120928123258.9454.95197.stgit@localhost.localdomain> <20120928.134417.1763308761361480629.davem@davemloft.net> <alpine.LNX.2.01.1211121941370.1611@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, paulius.zaleckas@gmail.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60769 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab2KLTBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 14:01:32 -0500
In-Reply-To: <alpine.LNX.2.01.1211121941370.1611@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2012 10:42 AM, Jan Engelhardt wrote:
> On Friday 2012-09-28 19:44, David Miller wrote:
>
>> From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
>> Date: Fri, 28 Sep 2012 15:32:58 +0300
>>
>>> vconfig help tells that vlan_id should be 0-4095, but fails
>>> with 4095.
>>>
>>> There is an off-by-one bug while evaluating vlan_id.
>>> Fix it by evaluating against count(4096), not mask(0x0fff = 4095).
>>>
>>> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
>>
>> Awesome, we don't need VXVLAN any more after this fix.
>
> You mean because the special 0xfff value could indicate "here's more
> headers"? Sounds like a plan.

You can't just use reserved values...they are for the standards writers
in case they ever need to officially extend the 802.1q spec somehow.

If you use it for non-standard purposes, you can set up conflicts with
future standards.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
