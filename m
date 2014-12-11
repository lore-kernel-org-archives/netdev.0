From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] net: introduce helper macro for_each_cmsghdr
Date: Thu, 11 Dec 2014 09:50:02 +0800
Message-ID: <5488F84A.8090303@cn.fujitsu.com>
References: <20141210.134804.1383875260695429574.davem@davemloft.net> <20141210.144430.1749715282635917425.davem@davemloft.net> <5488EDF7.7070001@cn.fujitsu.com> <20141210.204703.1525194278635097457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141210.204703.1525194278635097457.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
On 12/11/2014 09:47 AM, David Miller wrote:

> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Date: Thu, 11 Dec 2014 09:05:59 +0800
> 
>> IMO, the user-land programs need to be build with the matched
>> headers separately.
> 
> You absolutely cannot provide this new interface to userland and
> expect programs to be able to just use it, it's non-standard and does
> not exist in older headers.

Got it, sorry for my mistake, and thanks for your correction.

> 
> I do not want this new interface available to userland programs.
> They can just open-code the list traversal just like every program
> in history has had to do since BSD UNIX.

Agree. Let's leave the user-land ones as they are.
I'll send a new version (without changing user-land ones) soon.

Best regards,
Gu

> .
> 
