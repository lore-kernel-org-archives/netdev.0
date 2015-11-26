From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/7] net: ipmr: more cleanups and mfc netlink
 support
Date: Thu, 26 Nov 2015 17:48:47 +0100
Message-ID: <565737EF.9030504@cumulusnetworks.com>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
 <20151126163502.GB4094@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34942 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbbKZQst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 11:48:49 -0500
Received: by wmuu63 with SMTP id u63so28186923wmu.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:48:48 -0800 (PST)
In-Reply-To: <20151126163502.GB4094@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2015 05:35 PM, Andrew Lunn wrote:
> On Thu, Nov 26, 2015 at 03:23:43PM +0100, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> Hi,
>> This set continues with the minor cleanups in the first 6 patches and
>> patch 7 adds the first new feature - MFC manipulation via netlink.
> 
> Hi Nikolay
> 
> Great to see somebody working on multicast.
> 
> Do you have any plans to remove the 32 VIF limit?
> 
> I've run out if VIFs on a VPN server with lots of clients. I took the
> "quick fix" of recompiling the kernel and userspace with 256 VIFs. But
> it would be nice if you could define a netlink API which does not have
> this limit and modify the core code to be more dynamic.
> 
>      Andrew
> 

Hi Andrew,
I'm glad people are still using it. :-)  To answer your question - yes, I plan
to remove that limit, in fact I have a private version where it's done and this
API is the first step, you can see it uses the generic rtnh which supports
ifindex passing, so it'll be a matter of a few small changes to remove it.
The hardest part is keeping current user-space compatible with everything, but
I have the necessary workarounds for that. In the end it should be much more
usable and to some extent without mrtsock application running as well.

Thanks,
 Nik
