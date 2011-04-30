From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix incorrect unregistration of sysctl when last
 ip deleted
Date: Fri, 29 Apr 2011 20:47:14 -0700 (PDT)
Message-ID: <20110429.204714.193727944.davem@davemloft.net>
References: <201104272312.p3RNCcl6002068@jgmyers-vm1.eng.proofpoint.com>
	<20110429.134524.116375005.davem@davemloft.net>
	<4DBB3480.9020708@proofpoint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgmyers@proofpoint.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DBB3480.9020708@proofpoint.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Gardiner Myers <jgmyers@proofpoint.com>
Date: Fri, 29 Apr 2011 14:58:24 -0700

> The "how" parameter indicates the device is being deleted. In this
> case, the device is not being deleted.

It means that ipv6 is being disabled on the device.

Which is what happens when one of the following happens:

1) the MTU is too small to support ipv6 properly

2) no configured ipv6 addresses remain on the device

3) the device is being unregistered
