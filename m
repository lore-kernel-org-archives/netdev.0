From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Wed, 13 Jan 2016 23:56:43 -0500 (EST)
Message-ID: <20160113.235643.1373342973936029804.davem@davemloft.net>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <20160110.172558.367101858392871618.davem@davemloft.net>
 <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Wed, 13 Jan 2016 23:10:57 +0000

> I have done a comparison of the Toeplitz v.s. Jenkins Hash algorithms, 
> and found that the Toeplitz provides much better distribution of the 
> connections into send-indirection-table entries.

This fails to take into consideration how massively more expensive
Toeplitz is to compute.

This also fails to show what the real life performance implications
are.

Just showing distributions is meaningless if it doesn't indicate
what kind of performance distrubtion A or B achieves.
