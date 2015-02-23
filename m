From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] net/atm/signaling.c: replace
 current->state by __set_current_state()
Date: Mon, 23 Feb 2015 17:20:40 -0500 (EST)
Message-ID: <20150223.172040.411503206530965775.davem@davemloft.net>
References: <1424712667-11849-1-git-send-email-fabf@skynet.be>
	<20150223125025.61a25b4a@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabf@skynet.be, linux-kernel@vger.kernel.org, peterz@infradead.org,
	netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150223125025.61a25b4a@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Mon, 23 Feb 2015 12:50:25 -0500

> Instead of fixing code that never gets compiled/test, you could probably
> just remove the #if WAIT_FOR_DAEMON code which would get rid of this
> raw assignment.
> 
> See the #undef around line 268.

I completely agree.
