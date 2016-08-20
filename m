From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Implement batching of receive
 completions
Date: Fri, 19 Aug 2016 22:41:50 -0700 (PDT)
Message-ID: <20160819.224150.1875879736932632688.davem@davemloft.net>
References: <1471643229-2918-1-git-send-email-haiyangz@linuxonhyperv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@linuxonhyperv.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1471643229-2918-1-git-send-email-haiyangz@linuxonhyperv.com>
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

From: Haiyang Zhang <haiyangz@linuxonhyperv.com>
Date: Fri, 19 Aug 2016 14:47:09 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> The existing code uses busy retry when unable to send out receive
> completions due to full ring buffer. It also gives up retrying after limit
> is reached, and causes receive buffer slots not being recycled.
> This patch implements batching of receive completions. It also prevents
> dropping receive completions due to full ring buffer.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks.
