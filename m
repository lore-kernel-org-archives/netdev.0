From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH] enabling netdev boot options (2.6.0-t9)
Date: Sun, 9 Nov 2003 11:55:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031109115535.A1282@sygehus.dk>
References: <20031108160441.3a0a5505.rddunlap@osdl.org> <20031108204406.5dbbdc87.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, saw@saw.sw.com.sg, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031108204406.5dbbdc87.rddunlap@osdl.org>; from rddunlap@osdl.org on Sat, Nov 08, 2003 at 08:44:06PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 08, 2003 at 08:44:06PM -0800, Randy.Dunlap wrote:
> 
> Here's an update for 2.6.0-test9.  This update adds
> dev_alloc_name_lock(), which takes and releases the rtnl lock
> to call dev_alloc_name(), so that the caller doesn't have to do that.
> 
> More comments?

I don't like that name for the function. dev_alloc_name_lock() makes it
natural to think that there is a matching dev_alloc_name_unlock() function
which you should call afterwards. How about dev_alloc_name_locked() or
dev_alloc_name_with_lock() instead?

-- 
Regards,
Rask Ingemann Lambertsen
