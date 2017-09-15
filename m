From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: increase default receive buffer size
Date: Fri, 15 Sep 2017 14:48:00 -0700 (PDT)
Message-ID: <20170915.144800.2030136921935006857.davem@davemloft.net>
References: <20170914163107.8404-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com, sthemmin@microsoft.com,
 devel@linuxdriverproject.org
To: stephen@networkplumber.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170914163107.8404-1-sthemmin@microsoft.com>
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

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 14 Sep 2017 09:31:07 -0700

> The default receive buffer size was reduced by recent change
> to a value which was appropriate for 10G and Windows Server 2016.
> But the value is too small for full performance with 40G on Azure.
> Increase the default back to maximum supported by host.
> 
> Fixes: 8b5327975ae1 ("netvsc: allow controlling send/recv buffer size")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
