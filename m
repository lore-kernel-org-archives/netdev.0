From: Ben Greear <greearb@candelatech.com>
Subject: Re: Kernel splat with debugging on 3.3.6+ kernel.
Date: Fri, 18 May 2012 15:46:55 -0700
Message-ID: <4FB6D15F.6020006@candelatech.com>
References: <4FB697AB.10809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48441 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967348Ab2ERWq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 18:46:56 -0400
In-Reply-To: <4FB697AB.10809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2012 11:40 AM, Ben Greear wrote:
> This is a patched kernel, but nothing proprietary loaded.
>
> We're chasing a hard-to-reproduce bug that appears to be stale
> memory access related to wifi stations.
>
> So, I enabled a bunch of debugging (memory debugging, lockdep, etc)
> and this lockup occurs every time we try to load our
> '400 station' test case.
>
> I'm going to poke at this some more, try some smaller test
> cases and such, but if anyone has any other suggestions I'm interested!

I think with the amount of mem debugging I have enabled,
I just cannot use this many virtual stations.

The problem goes away when we have "only" 100 or so virtual
stations enabled...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
