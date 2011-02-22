From: Henry Nestler <henry.nestler@gmail.com>
Subject: Re: [PATCH 2/2] DM9000B: Fix PHY power for network down/up
Date: Tue, 22 Feb 2011 20:58:20 +0100
Message-ID: <4D64155C.9050407@henry.nestler.mail.gmail.com>
References: <4D618B5D.5040001@henry.nestler.mail.gmail.com> <4D62491F.4050602@ru.mvista.com> <4D62D323.7010403@henry.nestler.mail.gmail.com> <20110222.102410.260079835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: sshtylyov@mvista.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Sergei Shtylyov <sshtylyov@mvista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59469 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab1BVT6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 14:58:48 -0500
Received: by fxm17 with SMTP id 17so3127790fxm.19
        for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 11:58:46 -0800 (PST)
In-Reply-To: <20110222.102410.260079835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On 22.02.2011 19:24, David Miller wrote:
> From: Henry Nestler <henry.nestler@gmail.com>
> Date: Mon, 21 Feb 2011 22:03:31 +0100
> 
>> On 21.02.2011 12:14, Sergei Shtylyov wrote:
>>> On 21-02-2011 0:45, Henry Nestler wrote:
>>>> +	udelay(1000); /* delay needs by DM9000B */
>>>
>>>     Why not mdelay(1)?
>>
>> Because udelay is the base of mdelay.
>> See include/linux/delay.h:31
>>
>> #define mdelay(n) ... udelay((n)*1000)
> 
> He is telling you to use mdelay(1) because it's clearer.  Please do
> so.

Thanks, that text explains it better. No problem. I will resend this patch.

-- 
Henry N.
