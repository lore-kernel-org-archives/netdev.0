From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1 V2] hyperv: Fix a bug in netvsc_start_xmit()
Date: Tue, 30 Sep 2014 01:21:55 -0400 (EDT)
Message-ID: <20140930.012155.1518822116021687917.davem@davemloft.net>
References: <1411967803-29233-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1411967803-29233-1-git-send-email-kys@microsoft.com>
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
Date: Sun, 28 Sep 2014 22:16:43 -0700

> After the packet is successfully sent, we should not touch the skb 
> as it may have been freed. This patch is based on the work done by 
> Long Li <longli@microsoft.com>.
> 
> In this version of the patch I have fixed issues pointed out by David.
> David, please queue this up for stable.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Tested-by: Long Li <longli@microsoft.com>

Applied and queued up for -stable.
