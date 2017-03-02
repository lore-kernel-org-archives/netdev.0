From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] netvsc: fix use-after-free in netvsc_change_mtu()
Date: Thu, 2 Mar 2017 09:06:52 -0800
Message-ID: <20170302090652.2e9e4471@xeon-e3>
References: <MWHPR03MB266949159A2BCA01B5EBB778BF280@MWHPR03MB2669.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <sthemmin@microsoft.com>, netdev <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
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

On Thu, 2 Mar 2017 13:00:53 +0000
Dexuan Cui <decui@microsoft.com> wrote:

> 'nvdev' is freed in rndis_filter_device_remove -> netvsc_device_remove ->
> free_netvsc_device, so we mustn't access it, before it's re-created in
> rndis_filter_device_add -> netvsc_device_add.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Stephen Hemminger <sthemmin@microsoft.com>

Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
