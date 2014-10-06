From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: Quiet W=1 warnings for unused vars
 and static functions
Date: Mon, 06 Oct 2014 17:56:12 -0400 (EDT)
Message-ID: <20141006.175612.1709169088283433326.davem@davemloft.net>
References: <1412632298.2916.42.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.fastabend@gmail.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412632298.2916.42.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 06 Oct 2014 14:51:38 -0700

> Reduce noise when compiling W=1.
> 
> All the variables are unused.
> The functions are not called outside of the file so static
> is preferred.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> John, can you please verify that these gen_stats accesses
> are unnecessary?  I believe the compiler can elide them in
> any case, but I'm not sure what you intended here.

BTW, this patch reminds me that if people think there are
subdirectories where we can turn on things like -Werror in the
networking I would be very happy to apply such patches.

Things like arch/sparc has had this for years, I even forget when I
added it. :-)

Things like net/core/ for example should be doable for sure.
