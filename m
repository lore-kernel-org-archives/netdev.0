From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix an infinite retry-loop
Date: Sun, 04 Jan 2015 23:48:38 -0500 (EST)
Message-ID: <20150104.234838.596521437683943688.davem@davemloft.net>
References: <1420394696-20099-1-git-send-email-me@mortis.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jitendra.kalsaria@qlogic.com,
	ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: me@mortis.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420394696-20099-1-git-send-email-me@mortis.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Giel van Schijndel <me@mortis.eu>
Date: Sun,  4 Jan 2015 19:04:55 +0100

> This was clearly intended as a retry-10-times loop, but due to the
> absence of code incrementing the loop-counter it was practically a
> retry-forever loop.
> 
> Rewritten it as a for-loop as well to make the loop-counter increment
> (as well as its potential absence) easier to spot.

Besides missing the Signoff, you also did not write your
Subject line properly.

You should format it as:

Subject: [PATCH] ${SUBSYSTEM_PREFIX}: Description.

Where ${SUBSYSTEM_PREFIX} should be "qlogic: " in this
case.

Do not fix this by replying to this email, instead make a new
fresh patch posting to the lists.

This also applied to all of your other submissions, they all
need to be fixed up in this manner at the very least.
