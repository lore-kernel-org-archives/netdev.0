From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hso: remove some dead code
Date: Thu, 06 Feb 2014 22:30:06 -0800 (PST)
Message-ID: <20140206.223006.787392520247377485.davem@davemloft.net>
References: <20140206125319.GC16998@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140206125319.GC16998@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 6 Feb 2014 15:53:19 +0300

> It seems like this function was intended to have special handling for
> urb statuses of -ENOENT and -ECONNRESET.  But now it just prints some
> debugging and returns at the start of the function.
> 
> I have removed the dead code, it's still in the git history if anyone
> wants to revive it.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
