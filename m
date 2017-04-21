From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] netvsc: Deal with rescinded channels
 correctly
Date: Fri, 21 Apr 2017 13:51:29 -0400 (EDT)
Message-ID: <20170421.135129.972459595313792070.davem@davemloft.net>
References: <1492635229-29075-1-git-send-email-kys@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, sthemmin@microsoft.com, netdev@vger.kernel.org,
 jasowang@redhat.com, linux-kernel@vger.kernel.org, marcelo.cerri@canonical.com,
 apw@canonical.com, devel@linuxdriverproject.org,
 leann.ogasawara@canonical.comi
To: kys@microsoft.com, kys@exchange.microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1492635229-29075-1-git-send-email-kys@exchange.microsoft.com>
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
Date: Wed, 19 Apr 2017 13:53:49 -0700

> From: K. Y. Srinivasan <kys@microsoft.com>
> 
> We will not be able to send packets over a channel that has been
> rescinded. Make necessary adjustments so we can properly cleanup
> even when the channel is rescinded. This issue can be trigerred
> in the NIC hot-remove path.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
