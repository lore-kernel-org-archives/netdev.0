From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: remove MTU limits on a few ether_setup callers
Date: Fri, 21 Oct 2016 13:58:28 -0400 (EDT)
Message-ID: <20161021.135828.966455231750113733.davem@davemloft.net>
References: <20161021032527.12954-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        asbjorn@asbjorn.st, parameswaran.r7@gmail.com
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161021032527.12954-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Thu, 20 Oct 2016 23:25:27 -0400

> These few drivers call ether_setup(), but have no ndo_change_mtu, and thus
> were overlooked for changes to MTU range checking behavior. They
> previously had no range checks, so for feature-parity, set their min_mtu
> to 0 and max_mtu to ETH_MAX_MTU (65535), instead of the 68 and 1500
> inherited from the ether_setup() changes. Fine-tuning can come after we get
> back to full feature-parity here.
> 
> CC: netdev@vger.kernel.org
> Reported-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
> CC: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
> CC: R Parameswaran <parameswaran.r7@gmail.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Applied.

Please use "[PATCH net-next]" in your subject line when a patch
targets net-next.
