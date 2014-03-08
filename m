From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/6] Drivers: net: hyperv: Enable scatter gather I/O
Date: Sat, 08 Mar 2014 18:38:07 -0500 (EST)
Message-ID: <20140308.183807.1351815817743999901.davem@davemloft.net>
References: <fd6bb08bd9a447aa9c0da3b584ea9bb8@BY2PR03MB299.namprd03.prod.outlook.com>
 <20140308.013658.918013334851017662.davem@davemloft.net>
 <c72c0d17b4bd405cb218ab09b1c2e77e@BY2PR03MB299.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <c72c0d17b4bd405cb218ab09b1c2e77e@BY2PR03MB299.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: KY Srinivasan <kys@microsoft.com>
Date: Sat, 8 Mar 2014 10:27:54 +0000

> "len" would have gotten decremented prior to the check and in the
> case we are talking about, "len" would be zero and so j would not
> get incremented.

You are correct, this is the part of the logic in this case which I
missed.

Thanks.
