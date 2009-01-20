From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 4/6] arm: convert realview platform to use smsc911x
Date: Tue, 20 Jan 2009 13:44:19 +0000
Message-ID: <1232459059.14671.80.camel@pc1117.cambridge.arm.com>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com>
	 <1232458114-10997-2-git-send-email-steve.glendinning@smsc.com>
	 <1232458114-10997-3-git-send-email-steve.glendinning@smsc.com>
	 <1232458114-10997-4-git-send-email-steve.glendinning@smsc.com>
	 <1232458114-10997-5-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:51093 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755280AbZATNo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 08:44:57 -0500
In-Reply-To: <1232458114-10997-5-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 13:28 +0000, Steve Glendinning wrote:
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  arch/arm/mach-realview/core.c |   17 +++++++++--------
>  1 files changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c

The RealView changes look fine but I'll need to test them in an ARM SMP
configuration. Last time I tried a version of this driver (though not
the latest), it didn't work properly with SMP enabled (but couldn't
figure why).

I'll give the latest driver a try sometime this week and let you know.

-- 
Catalin

