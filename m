From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/hyperv: Fix data corruption in
	rndis_filter_receive()
Date: Fri, 09 Mar 2012 13:51:23 -0800 (PST)
Message-ID: <20120309.135123.2098113809216101768.davem@davemloft.net>
References: <1331328437-26852-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1331328437-26852-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri,  9 Mar 2012 13:27:16 -0800

> Limiting the memcpy to be the sizeof(struct rndis_message) can truncate
> the message if there are Per-Packet-Info or Out-of-Band data.
> 
> In my earlier patch (commit 45326342), the unnecessary kmap_atomic and
> kunmap_atomic surrounding this memcpy have been removed because the memory
> in the receive buffer is always mapped. This memcpy is not necessary
> either. To fix the bug, I removed the memcpy.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Well, where the heck is patch 2/2?
