From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Wed, 27 Sep 2006 11:44:47 +0200
Message-ID: <451A480F.7050404@trash.net>
References: <20060926183621.GX18349@postel.suug.ch> <Pine.LNX.4.44.0609271104470.9010-100000@dhcp09282.ntc.nokia.com> <20060927093301.GY18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:21685 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965483AbWI0Jou
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 05:44:50 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060927093301.GY18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Nordlund Kim (Nokia-NET/Helsinki) <Kim.Nordlund@nokia.com> 2006-09-27 11:50
> 
>>So I would suggest to apply this patch to be compatible with the
>>GCC version in RHEL5, and simply to make code clearer (to the
>>intended idea).
> 
> 
> Yes.

I don't care much about this small change, but I think bugs
should be fixed where they originate. If RH's gcc miscompiles
this with -Os I wouldn't trust it anyway, and the easy way to
fix it seems to be to deactivate CONFIG_CC_OPTIMIZE_FOR_SIZE,
which even includes a big warning of broken compilers.
What about the similar code in u32 and cbq?

