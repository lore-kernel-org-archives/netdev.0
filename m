From: Ben Greear <greearb@candelatech.com>
Subject: Re: Fw: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
Date: Sat, 06 May 2006 10:20:01 -0700
Message-ID: <445CDAC1.2010209@candelatech.com>
References: <20060504235628.33041b55.akpm@osdl.org>	<445B75D2.6080702@candelatech.com>	<20060505193903.249feaf8.akpm@osdl.org>	<445C2872.5060208@candelatech.com> <20060505231759.5ad77e95.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:2788 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750916AbWEFRUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 May 2006 13:20:10 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060505231759.5ad77e95.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

> I guess I can type simple commands and add printks.  Do you have time to
> take a look at the driver and suggest what I should be looking for?

I can only offer vague hints:

TX usually works, but RX often has isues.  There is usually a bit
or two that needs setting to enable the larger than MTU pkt RX.

It seems some older chipsets had issues with doing checksum offload
for VLAN packets, so could try disabling the UDP/TCP checksum logic
and see if that helps.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

