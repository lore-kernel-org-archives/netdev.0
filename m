From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Mon, 28 Jan 2008 19:43:14 -0500
Message-ID: <479E76A2.8020304@garzik.org>
References: <1199403419.25262.62.camel@localhost.localdomain> <6D762C47-9C9C-422E-A80E-CC418F624B05@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nate Case <ncase@xes-inc.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41766 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbYA2AnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 19:43:22 -0500
In-Reply-To: <6D762C47-9C9C-422E-A80E-CC418F624B05@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> Jeff, Dave, any chance we can get this one in for 2.6.25?  It will allow 
> a number of other drivers to start using PHY Lib.
> I'm sure Nate can resend if needed.
> 
> On Jan 3, 2008, at 17:36, Nate Case wrote:
> 
>> PHY read/write functions can potentially sleep (e.g., a PHY accessed
>> via I2C).  The following changes were made to account for this:
>>
>>     * Change spin locks to mutex locks
>>     * Add a BUG_ON() to phy_read() phy_write() to warn against
>>       calling them from an interrupt context.
>>     * Use work queue for PHY state machine handling since
>>       it can potentially sleep
>>     * Change phydev lock from spinlock to mutex
>>
>> Signed-off-by: Nate Case <ncase@xes-inc.com>

don't see it in my queue, so please resend.


