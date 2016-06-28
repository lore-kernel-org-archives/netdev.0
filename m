From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v12 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 28 Jun 2016 09:45:02 -0400 (EDT)
Message-ID: <20160628.094502.1492727757715500496.davem@davemloft.net>
References: <BLUPR03MB1410A0ECB526A1CD13814D36BF2E0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160628.053350.1891488485477523405.davem@davemloft.net>
 <CO2PR03MB2182CC1DA2804F09D8D77A70BF220@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, joe@perches.com, netdev@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, vkuznets@redhat.com,
 cavery@redhat.com, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CO2PR03MB2182CC1DA2804F09D8D77A70BF220@CO2PR03MB2182.namprd03.prod.outlook.com>
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
Date: Tue, 28 Jun 2016 09:59:21 +0000

> The idea here is: IMO the syscalls sys_read()/write() shoudn't return
> -ENOMEM, so I have to make sure the buffer allocation succeeds?

You have to fail if resources cannot be allocated.
