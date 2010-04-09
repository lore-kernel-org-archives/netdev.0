From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: FEC driver: rcv is not +last
Date: Fri, 09 Apr 2010 13:42:47 +0800
Message-ID: <4BBEBE57.8020800@canonical.com>
References: <20100408104033.GI3787@darwin>
Reply-To: bryan.wu@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>
To: Matthias Kaehlcke <matthias@kaehlcke.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:35407 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab0DIFnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 01:43:10 -0400
In-Reply-To: <20100408104033.GI3787@darwin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2010 06:40 PM, Matthias Kaehlcke wrote:
> hi,
>
> i have problems with the FEC on a i.MX25 3-Stack board. the kernel is
> v2.6.34-rc2 plus the following patch:
> http://patchwork.ozlabs.org/patch/41235/
>
> the following traces are generated at boot time:
>
> FEC Ethernet Driver
> fec: PHY @ 0x1, ID 0x20005ce1 -- unknown PHY!
> ...

Matt,

please try this patch on your hardware, it introduced phylib supporting in fec.c 
driver:
http://lists.infradead.org/pipermail/linux-arm-kernel/2010-March/012214.html

Thanks
-- 
Bryan Wu <bryan.wu@canonical.com>
Kernel Developer    +86.138-1617-6545 Mobile
Ubuntu Kernel Team | Hardware Enablement Team
Canonical Ltd.      www.canonical.com
Ubuntu - Linux for human beings | www.ubuntu.com
