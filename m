From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: fix build for CONFIG_SYSFS disabled
Date: Mon, 17 May 2010 22:32:37 -0700 (PDT)
Message-ID: <20100517.223237.55871633.davem@davemloft.net>
References: <20100517091756.e232bdc2.randy.dunlap@oracle.com>
	<20100517105654.2451e61f@nehalam>
	<4BF18468.5010005@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4BF18468.5010005@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 17 May 2010 11:01:12 -0700

> On 05/17/10 10:56, Stephen Hemminger wrote:
>> On Mon, 17 May 2010 09:17:56 -0700
>> Randy Dunlap <randy.dunlap@oracle.com> wrote:
>> 
>>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>>
>>> Fix build when CONFIG_SYSFS is not enabled:
>>>
>>> net/bridge/br_if.c:136: error: 'struct net_bridge_port' has no member named 'sysfs_name'
>>>
>>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
...
>> I don't like peppering code with #ifdef like this.
> 
> Thanks.  I didn't like it either.
> 
>> Turns out that in this place sysfs_name is always the same
>> as the device name so instead:

Stephen, please give me a formal submission of this fix with proper
signoff and credit to Randy.

Thanks!
