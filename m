From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdnloop: use strlcpy() instead of strcpy()
Date: Thu, 14 Nov 2013 16:50:54 -0500 (EST)
Message-ID: <20131114.165054.356251797193140551.davem@davemloft.net>
References: <20131114082110.GD8150@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de,
	kernel-janitors@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20131114082110.GD8150@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 14 Nov 2013 11:21:10 +0300

> These strings come from a copy_from_user() and there is no way to be
> sure they are NUL terminated.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied and queued up for -stable, thanks Dan.
