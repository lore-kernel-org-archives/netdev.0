From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux IP forwarding performance benchmarks
Date: Sat, 08 Dec 2012 10:44:18 -0800
Message-ID: <50C38A82.5050506@candelatech.com>
References: <1219381354968093@web3d.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Oleg Arkhangelsky <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40243 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965492Ab2LHSoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2012 13:44:20 -0500
In-Reply-To: <1219381354968093@web3d.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 04:01 AM, Oleg Arkhangelsky wrote:
> Hello,
>
> Does anyone have some Linux IP forwarding performance
> benchmarks on Nehalem Xeon platform versus Sandy
> Bridge Xeon E5? Intel DDIO looks pretty tasty and should
> give significant  performance boost (at least in theory)
> but currently we doesn't have this hardware at hand to
> test so asking here.

Well, I don't have forwarding numbers, but using a modified pktgen,
we can send and receive about 800,000 packets per second on each of
4 10G NICs in our E5 test system.

Our modified pktgen is probably slower than the upstream, as it has
a bunch of rx logic in it as well...

And, for our network emulator module (like a bridge, mostly), we can
get 7-9.8Gbps bi-directional throughput, depending on some issues
due to IRQ pinning and the spread among the rx-queues, it seems.

Thanks,
Ben

>
> Thank you!
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
