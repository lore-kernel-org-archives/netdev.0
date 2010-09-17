From: David Miller <davem@davemloft.net>
Subject: Re: [Security] [PATCH v4] drivers/net/tulip/de4x5.c: fix union
 member name in DE4X5_GET_REG ioctl
Date: Thu, 16 Sep 2010 23:53:05 -0700 (PDT)
Message-ID: <20100916.235305.233408955.davem@davemloft.net>
References: <1284701436.2565.6.camel@dan>
	<20100916.223441.93463391.davem@davemloft.net>
	<20100917063602.GA2341@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, security@kernel.org,
	grundler@parisc-linux.org, netdev@vger.kernel.org, jeffm@suse.com,
	linux-kernel@vger.kernel.org, kyle@mcmartin.ca
To: w@1wt.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100917063602.GA2341@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 17 Sep 2010 08:36:02 +0200

> On Thu, Sep 16, 2010 at 10:34:41PM -0700, David Miller wrote:
>> From: Dan Rosenberg <drosenberg@vsecurity.com>
>> Date: Fri, 17 Sep 2010 01:30:36 -0400
>> 
>> > Tiring doesn't begin to describe it.  Formatting undamaged.
>> 
>> :-)  Thanks.
>> 
>> > This was previously reported as a security issue due to leakage of
>> > uninitialized stack memory.  Jeff Mahoney pointed out that this is
>> > incorrect since the copied data is from a union (rather than a struct).
>> > Therefore, this patch is only under consideration for the sake of
>> > correctness, and is not security relevant. 
>> > 
>> > Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
>> > Acked-by: Grant Grundler <grundler@parisc-linux.org>
>> 
>> Applied.
> 
> David, just for the record, as was already reported on the list, this
> fix is finally more a cleanup than a security fix because "tmp" is a
> union and not a struct, so tmp.addr == tmp.lval.

I can read, thanks :-)

That's why I applied it to net-next-2.6 and not net-2.6
