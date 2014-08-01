From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ISDN: pcbit: off by one bugs in pcbit_set_msn()
Date: Thu, 31 Jul 2014 22:15:29 -0700 (PDT)
Message-ID: <20140731.221529.330940073121612159.davem@davemloft.net>
References: <20140731153011.GF31539@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, arnd@arndb.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140731153011.GF31539@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 31 Jul 2014 18:30:11 +0300

> 1) We don't allocate enough space for the NUL terminator so we end up
>    corrupting one character beyond the end of the buffer.
> 
> 2) The "len - 1" should just be "len".  The code is trying to copy a
>    word from a buffer up to a comma or the last word in the buffer.
>    Say you have the buffer, "foo,bar,baz", then this code truncates the
>    last letter off each word so you get "fo", "ba", and "ba".  You would
>    hope this kind of bug would get noticed in testing...
> 
>    I'm not very familiar with this code and I can't test it, but I think
>    we should copy the final character.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks Dan.
