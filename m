From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: Quiet W=1 warnings for unused vars
 and static functions
Date: Mon, 06 Oct 2014 18:19:40 -0400 (EDT)
Message-ID: <20141006.181940.852741335799941670.davem@davemloft.net>
References: <1412632298.2916.42.camel@joe-AO725>
	<20141006.175612.1709169088283433326.davem@davemloft.net>
	<1412633064.2916.46.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.fastabend@gmail.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412633064.2916.46.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 06 Oct 2014 15:04:24 -0700

> On Mon, 2014-10-06 at 17:56 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Mon, 06 Oct 2014 14:51:38 -0700
>> 
>> > Reduce noise when compiling W=1.
> []
>> BTW, this patch reminds me that if people think there are
>> subdirectories where we can turn on things like -Werror in the
>> networking I would be very happy to apply such patches.
> []
>> Things like net/core/ for example should be doable for sure.
> 
> I don't have any significant opposition to -Werror, but
> I think there are real arguments _against_ using -Werror.
> 
> I think the primary one is new compiler versions have a
> tendency to add new warnings for various things that can
> unnecessarily and unpredictably break the build.

My experience over at least a decade with arch/sparc doesn't match
your claims.
