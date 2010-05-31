From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Mon, 31 May 2010 06:02:25 -0700 (PDT)
Message-ID: <20100531.060225.68146363.davem@davemloft.net>
References: <alpine.LNX.2.00.1005312011210.469@nippy.intranet>
	<20100531.043056.258120791.davem@davemloft.net>
	<alpine.OSX.2.00.1005312244520.1490@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, joe@perches.com, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1005312244520.1490@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Mon, 31 May 2010 22:55:23 +1000 (EST)

> if (ei_debug)
> 	pr_debug(...)
> 
> OR
> 
> if (ei_debug)
> 	pr_info(...)

Well for the printk in question, it's telling the user that
a certain feature can't be enabled.

And if the driver has an explicit way to control this message,
using ei_debug, it's kind of redundant to slap another layer on
top by using the debug printk facility.

Changing this to a debug log level printk is only going to make
getting the debug message shown harder for the user.  So leaving it at
pr_info() is just as correct in my eyes.

Finally, your patch has so many problems getting applied because
you're doing multiple things in one patch.

And in fact I've asked you not to do this on several occiaions.

Fix the error return codes in one patch, and nothing more.
Then in another you can masterbate with printk log levels.
