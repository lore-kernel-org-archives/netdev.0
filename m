From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netvsc: fix dereference before null check errors
Date: Mon, 27 Mar 2017 16:01:19 -0700 (PDT)
Message-ID: <20170327.160119.277346270230368504.davem@davemloft.net>
References: <20170325142639.11452-1-colin.king@canonical.com>
 <BLUPR03MB141236E1502819C7B992C9F9CA330@BLUPR03MB1412.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sthemmin@microsoft.com, netdev@vger.kernel.org,
 kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, colin.king@canonical.com
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BLUPR03MB141236E1502819C7B992C9F9CA330@BLUPR03MB1412.namprd03.prod.outlook.com>
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
Date: Mon, 27 Mar 2017 00:50:27 +0000

> 
> 
>> -----Original Message-----
>> From: Colin King [mailto:colin.king@canonical.com]
>> Sent: Saturday, March 25, 2017 10:27 AM
>> To: KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
>> <haiyangz@microsoft.com>; Stephen Hemminger <sthemmin@microsoft.com>;
>> devel@linuxdriverproject.org; netdev@vger.kernel.org
>> Cc: kernel-janitors@vger.kernel.org; linux-kernel@vger.kernel.org
>> Subject: [PATCH] netvsc: fix dereference before null check errors
>> 
>> From: Colin Ian King <colin.king@canonical.com>
>> 
>> ndev is being checked to see if it is a null pointer however before
>> the null check ndev is being dereferenced; hence there is a potential
>> null pointer dereference bug that needs fixing. Fix this by only
>> dereferencing ndev after the null check.
>> 
>> Detected by CoverityScan, CID#1420760, CID#140761 ("Dereference
>> before null check")
>> 
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
