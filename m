From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,2/2] hyperv: Fix RNDIS send_completion code path
Date: Mon, 08 Apr 2013 12:16:20 -0400 (EDT)
Message-ID: <20130408.121620.1034249208373430154.davem@davemloft.net>
References: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
 <1365198280-23270-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1365198280-23270-2-git-send-email-haiyangz@microsoft.com>
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
Date: Fri,  5 Apr 2013 14:44:40 -0700

> In some cases, the VM_PKT_COMP message can arrive later than RNDIS completion
> message, which will free the packet memory. This may cause panic due to access
> to freed memory in netvsc_send_completion().
> 
> This patch fixes this problem by removing rndis_filter_send_request_completion()
> from the code path. The function was a no-op.
> 
> Reported-by: Long Li <longli@microsoft.com>
> Tested-by: Long Li <longli@microsoft.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
