From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 14 Jan 2016 17:06:25 -0500 (EST)
Message-ID: <20160114.170625.332893838261533719.davem@davemloft.net>
References: <CALx6S34NWdBe0ZBuSMJCC8r68LOVvbY3ZXhneo+TSU1qz=9mYw@mail.gmail.com>
	<BN1PR0301MB0770C72CCEDD9AEBA7AEA329CACC0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<CALx6S349p_2XwFXM_T74PzSmJ6F9petkyX_5dY-PEp2O7Y9vfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, eric.dumazet@gmail.com,
	gnomes@lxorguk.ukuu.org.uk, vkuznets@redhat.com,
	netdev@vger.kernel.org, kys@microsoft.com,
	devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S349p_2XwFXM_T74PzSmJ6F9petkyX_5dY-PEp2O7Y9vfA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 14 Jan 2016 13:44:24 -0800

> The fact that we can negatively affect the output of Toeplitz so
> predictably is actually a liability and not a benefit. This sort of
> thing can be the basis of a DOS attack and is why we kicked out XOR
> hash in favor of Jenkins.

+1

Toeplitz should not be used for any software calculated flow hash
whatsoever.
