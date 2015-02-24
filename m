From: David Miller <davem@davemloft.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 11:57:23 -0500 (EST)
Message-ID: <20150224.115723.1094850542763908753.davem@davemloft.net>
References: <20150224104232.GK3713@acer.localdomain>
	<54ECA374.7060402@akamai.com>
	<20150224162521.GK3713@acer.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, daniel@iogearbox.net, tgraf@suug.ch,
	paulmck@linux.vnet.ibm.com, alexei.starovoitov@gmail.com,
	herbert@gondor.apana.org.au, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	josh@joshtriplett.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150224162521.GK3713@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 24 Feb 2015 16:25:22 +0000

> Thanks. I actually don't think we should require that parameter at
> all, any limits shouldn't be imposed by the data structure but by
> the code using it. We're perfectly fine using the available memory
> as a limit if the users wants this, provided that hash expansion
> succeeds and the lookups stay fast.
> 
> But for now let's just fix the immediate problem, I agree.

I agree, the behavior when the value is unspecified should be to grow
as needed without any limits.
