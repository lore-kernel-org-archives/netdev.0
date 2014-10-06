From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] hyperv: Fix a bug in netvsc_send()
Date: Sun, 05 Oct 2014 21:11:29 -0400 (EDT)
Message-ID: <20141005.211129.632749242463744635.davem@davemloft.net>
References: <1412530971-29897-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1412530971-29897-1-git-send-email-kys@microsoft.com>
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
Date: Sun,  5 Oct 2014 10:42:51 -0700

> After the packet is successfully sent, we should not touch the packet 
> as it may have been freed. This patch is based on the work done by
> Long Li <longli@microsoft.com>.
> 
> David, please queue this up for stable.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reported-by: Sitsofe Wheeler <sitsofe@yahoo.com>

Applied and queued up for -stable.
