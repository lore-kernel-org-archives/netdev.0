From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,1/2] hyperv: Fix a kernel warning from
 netvsc_linkstatus_callback()
Date: Mon, 08 Apr 2013 12:16:14 -0400 (EDT)
Message-ID: <20130408.121614.2170605259377916404.davem@davemloft.net>
References: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri,  5 Apr 2013 14:44:39 -0700

> The warning about local_bh_enable inside IRQ happens when disconnecting a
> virtual NIC.
> 
> The reason for the warning is -- netif_tx_disable() is called when the NIC
> is disconnected. And it's called within irq context. netif_tx_disable() calls
> local_bh_enable() which displays warning if in irq.
> 
> The fix is to remove the unnecessary netif_tx_disable & wake_queue() in the
> netvsc_linkstatus_callback().
> 
> Reported-by: Richard Genoud <richard.genoud@gmail.com>
> Tested-by: Long Li <longli@microsoft.com>
> Tested-by: Richard Genoud <richard.genoud@gmail.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
