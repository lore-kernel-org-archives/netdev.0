From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Wed, 16 Sep 2015 10:59:36 -0700 (PDT)
Message-ID: <20150916.105936.2275139635170756984.davem@davemloft.net>
References: <1442418625-11805-1-git-send-email-vkuznets@redhat.com>
	<BN1PR0301MB0770C47D37D272F5A28CD1DECA5B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB9800B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, vkuznets@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kys@microsoft.com, jasowang@redhat.com
To: David.Laight@ACULAB.COM
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB9800B@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 16 Sep 2015 16:25:03 +0000

> Am I right in thinking this is adding an extra 96 unused bytes to the front
> of almost all skb just so that hyper-v can make its link level header
> contiguous with whatever follows (IP header ?).
> 
> Doesn't sound ideal.

Agreed, this is rediculous, and the entire stack will incur this cost
just because hyperv is enabled in the kernel config.
