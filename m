From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netvsc: fix use-after-free in netvsc_change_mtu()
Date: Thu, 02 Mar 2017 14:43:43 -0800 (PST)
Message-ID: <20170302.144343.1942167578659107503.davem@davemloft.net>
References: <MWHPR03MB266949159A2BCA01B5EBB778BF280@MWHPR03MB2669.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sthemmin@microsoft.com, netdev@vger.kernel.org, haiyangz@microsoft.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <MWHPR03MB266949159A2BCA01B5EBB778BF280@MWHPR03MB2669.namprd03.prod.outlook.com>
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

From: Dexuan Cui <decui@microsoft.com>
Date: Thu, 2 Mar 2017 13:00:53 +0000

> 'nvdev' is freed in rndis_filter_device_remove -> netvsc_device_remove ->
> free_netvsc_device, so we mustn't access it, before it's re-created in
> rndis_filter_device_add -> netvsc_device_add.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>

Applied.
