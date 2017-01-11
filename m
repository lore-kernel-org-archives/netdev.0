From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: next-20170110 build: 1 failures 4 warnings (next-20170110)
Date: Wed, 11 Jan 2017 15:39:22 +0530
Message-ID: <d0fadcde-aa8a-74c9-b48b-98d8f53a3a1b@ti.com>
References: <E1cQqkO-0005XB-2K@optimist>
 <20170110181607.dp6giaxyeczykmv4@sirena.org.uk>
 <20170111072131.51449059@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linaro-kernel@lists.linaro.org, kernel-build-reports@lists.linaro.org,
 netdev@vger.kernel.org, stephen hemminger <stephen@networkplumber.org>,
 Michael Scherban <m-scherban@ti.com>, linux-next@vger.kernel.org,
 Murali Karicheri <m-karicheri2@ti.com>, "J, KEERTHY" <j-keerthy@ti.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, Mark Brown <broonie@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170111072131.51449059@canb.auug.org.au>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 January 2017 01:51 AM, Stephen Rothwell wrote:
> Hi Mark,
> 
> On Tue, 10 Jan 2017 18:16:07 +0000 Mark Brown <broonie@kernel.org> wrote:
>>
>> On Tue, Jan 10, 2017 at 07:21:32AM +0000, Build bot for Mark Brown wrote:
>>
>> Today's -next fails to build an arm allmodconfig due to:
>>
>>> 	arm-allmodconfig
>>> ../drivers/net/ethernet/ti/netcp_core.c:1951:28: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]  
>>
>> caused by 6a8162e99ef344 (net: netcp: store network statistics in 64
>> bits).  It's assigning the function
>>
>>   static struct rtnl_link_stats64 *
>>   netcp_get_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)
>>
>> to ndo_get_stats64 which expects a function returning void.
> 
> Yes, but only because commit bc1f44709cf2 ("net: make ndo_get_stats64 a
> void function") entered the net-next tree on the same day ... so it
> needs a followup fixup patch for this new usage.

Keerthy sent a patch fixing this yesterday. Looks like he will have to
spin another version though.

https://patchwork.ozlabs.org/patch/713224/

Thanks,
Sekhar
