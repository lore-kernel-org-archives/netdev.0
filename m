From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: make it possible for packets to traverse the
 bridge withour hitting netfilter
Date: Wed, 11 Feb 2015 14:29:36 -0800 (PST)
Message-ID: <20150211.142936.951620487173949333.davem@davemloft.net>
References: <1423560744-19011-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	imrep@amazon.de, aliguori@amazon.com
To: imrep.amz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423560744-19011-1-git-send-email-imrep.amz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Imre Palik <imrep.amz@gmail.com>
Date: Tue, 10 Feb 2015 10:32:24 +0100

> From: "Palik, Imre" <imrep@amazon.de>
> 
> The netfilter code is made with flexibility instead of performance in mind.
> So when all we want is to pass packets between different interfaces, the
> performance penalty of hitting netfilter code can be considerable, even when
> all the firewalling is disabled for the bridge.
> 
> This change makes it possible to disable netfilter both on a per bridge basis,
> or for the whole bridging subsystem.  In the case interesting to us, this can
> lead to more than 10% speedup compared to the case when only bridge-iptables
> are disabled.
> 
> Cc: Anthony Liguori <aliguori@amazon.com>
> Signed-off-by: Imre Palik <imrep@amazon.de>

Sorry, no.

If I apply this, someone is going to try to submit a patch for every
damn protocol layer to add a stupid hack like this.

Makw NF_HOOK() faster instead.
