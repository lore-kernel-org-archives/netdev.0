From: David Miller <davem@davemloft.net>
Subject: Re: error while building the kernel Mainline
Date: Thu, 18 Nov 2010 13:15:27 -0800 (PST)
Message-ID: <20101118.131527.45904827.davem@davemloft.net>
References: <20101118.125451.98885354.davem@davemloft.net>
	<20101118130318.073f6beb.randy.dunlap@oracle.com>
	<20101118.131004.58430322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, justinmattock@gmail.com, eric.dumazet@gmail.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, horms@verge.net.au,
	netfilter-devel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101118.131004.58430322.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 18 Nov 2010 13:10:04 -0800 (PST)

> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Thu, 18 Nov 2010 13:03:18 -0800
> 
>> On Thu, 18 Nov 2010 12:54:51 -0800 (PST) David Miller wrote:
>> 
>>> From: Patrick McHardy <kaber@trash.net>
>>> Date: Thu, 18 Nov 2010 21:32:11 +0100
>>> 
>>> > Thanks for testing. Dave, please apply directly, thanks!
>> 
>> Dave,
>> 
>> This patch does not fix the config/build error that I posted for linux-next.
> 
> And it has bugs, now when NF_CONNTRACT is set to "m" IPVS isn't offered
> at all.
> 
> So I'm reverting.

Ignore this, I was looking for "*_IPVS" in the config instead of
"*_IP_VS" for some stupid reason.

Patch is sane and I'll look into Randy's problem when I get a chance.
:-)
