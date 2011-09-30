From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/phy/icplus: Use mdiobus_write() and
 mdiobus_read() for proper locking.
Date: Fri, 30 Sep 2011 18:54:33 -0400 (EDT)
Message-ID: <20110930.185433.371029849281805679.davem@davemloft.net>
References: <1317421068-27278-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
        Gregory.Dietsche@cuw.edu, u.kleine-koenig@pengutronix.de,
        peppe.cavallaro@st.com
To: david.daney@cavium.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1317421068-27278-1-git-send-email-david.daney@cavium.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>
Date: Fri, 30 Sep 2011 15:17:48 -0700

> Usually you have to take the bus lock.  Why not here too?
> 
> I saw this when working on something else.  Not even compile tested.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>
> Cc: Greg Dietsche <Gregory.Dietsche@cuw.edu>
> Cc: "Uwe Kleine-Konig" <u.kleine-koenig@pengutronix.de>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied to net-next.
