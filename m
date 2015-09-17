From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Thu, 17 Sep 2015 11:03:25 +0200
Message-ID: <87k2rpwh7m.fsf@vitty.brq.redhat.com>
References: <1442418625-11805-1-git-send-email-vkuznets@redhat.com>
	<BN1PR0301MB0770C47D37D272F5A28CD1DECA5B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB9800B@AcuExch.aculab.com>
	<20150916.105936.2275139635170756984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David.Laight@ACULAB.COM, haiyangz@microsoft.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kys@microsoft.com, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150916.105936.2275139635170756984.davem@davemloft.net> (David
	Miller's message of "Wed, 16 Sep 2015 10:59:36 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: David Laight <David.Laight@ACULAB.COM>
> Date: Wed, 16 Sep 2015 16:25:03 +0000
>
>> Am I right in thinking this is adding an extra 96 unused bytes to the front
>> of almost all skb just so that hyper-v can make its link level header
>> contiguous with whatever follows (IP header ?).
>> 
>> Doesn't sound ideal.
>
> Agreed, this is rediculous, and the entire stack will incur this cost
> just because hyperv is enabled in the kernel config.

That's what 'RFC' in the subject was about :-)

We already have a precedent of increasing LL_MAX_HEADER globaly because
of a config option (CONFIG_MAC80211_MESH) but Hyper-V needs more.

-- 
  Vitaly
