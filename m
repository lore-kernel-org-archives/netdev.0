From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Sun, 26 Jul 2015 16:40:54 -0700 (PDT)
Message-ID: <20150726.164054.334062063521214575.davem@davemloft.net>
References: <1437590552-10211-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1437590552-10211-1-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed, 22 Jul 2015 11:42:32 -0700

> The current code returns from probe without waiting for the proper handling
> of subchannels that may be requested. If the netvsc driver were to be rapidly
> loaded/unloaded, we can  trigger a panic as the unload will be tearing
> down state that may not have been fully setup yet. We fix this issue by making
> sure that we return from the probe call only after ensuring that the
> sub-channel offers in flight are properly handled.
> 
> Reviewed-and-tested-by: Haiyang Zhang <haiyangz@microsoft.com
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
