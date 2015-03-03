From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 12:04:28 -0800
Message-ID: <1425413068.17273.58.camel@perches.com>
References: <1425409671.17273.42.camel@perches.com>
	 <20150303.142758.822602589629075339.davem@davemloft.net>
	 <1425411669.17273.52.camel@perches.com>
	 <20150303.145815.1129211297511474723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150303.145815.1129211297511474723.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 14:58 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 03 Mar 2015 11:41:09 -0800
> 
> > Until such time as the linux crosstools compilers are updated,
> > (they seem stuck on 4.6.3 from 3 years ago)
> > https://www.kernel.org/pub/tools/crosstool/
> > I think the series is a trivial, small improvement.
> 
> You are even admitting that even for your specific case you are
> using 3+ year old compiler technology.

That's what I said.  How is it an "admission"?
Those are the kernel.org "recommended" cross-compilers.

> These are slow paths, so correctness is the most important aspect.
> 
> Converting these locations to consistently use eth_*() is fine,
> but then "optimizing" a 6 by memset for configuration paths when
> the compiler should be more than capable of doing this just fine
> is not convincing at all to me.

Swell, then perhaps you could simply skip 1/14.
