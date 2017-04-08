From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] netvsc: Initialize all channel related
 state prior to opening the channel
Date: Sat, 08 Apr 2017 08:33:18 -0700 (PDT)
Message-ID: <20170408.083318.370417877208769419.davem@davemloft.net>
References: <1491515961-15624-1-git-send-email-kys@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, sthemmin@microsoft.com, netdev@vger.kernel.org,
 jasowang@redhat.com, linux-kernel@vger.kernel.org, marcelo.cerri@canonical.com,
 apw@canonical.com, devel@linuxdriverproject.org,
 leann.ogasawara@canonical.comi
To: kys@microsoft.com, kys@exchange.microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1491515961-15624-1-git-send-email-kys@exchange.microsoft.com>
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

From: kys@exchange.microsoft.com
Date: Thu,  6 Apr 2017 14:59:21 -0700

> From: K. Y. Srinivasan <kys@microsoft.com>
> 
> Prior to opening the channel we should have all the state setup to handle
> interrupts. The current code does not do that; fix the bug. This bug
> can result in faults in the interrupt path.
>  
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
