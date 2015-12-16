From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Use simple parser for IPv4 and v6
 headers
Date: Wed, 16 Dec 2015 18:23:10 -0500 (EST)
Message-ID: <20151216.182310.1967561459941374668.davem@davemloft.net>
References: <1450289022-9958-1-git-send-email-haiyangz@microsoft.com>
 <1450285688.8474.86.camel@edumazet-glaptop2.roam.corp.google.com>
 <BN1PR0301MB0770A1CB185D1AB82D5F9E44CAEF0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BN1PR0301MB0770A1CB185D1AB82D5F9E44CAEF0@BN1PR0301MB0770.namprd03.prod.outlook.com>
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
Date: Wed, 16 Dec 2015 19:20:44 +0000

> In our test, we have bisected and found the following patch introduced big 
> overhead into skb_flow_dissect_flow_keys(), and caused performance 
> regression:
> commit: d34af823
> net: Add VLAN ID to flow_keys

NEVER _EVER_ work around this kind of problem by bypassing the code in
question in your driver.

ALWAYS work to fix the actual problem.
