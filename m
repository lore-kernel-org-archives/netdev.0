From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: don't flush peers notifying work during
 setting mtu
Date: Tue, 17 Dec 2013 14:46:14 -0500 (EST)
Message-ID: <20131217.144614.1217520884557723259.davem@davemloft.net>
References: <1386926487-30822-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1386926487-30822-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 13 Dec 2013 17:21:27 +0800

> There's a possible deadlock if we flush the peers notifying work during setting
> mtu:
 ...
> Reported-by: Yaju Cao <yacao@redhat.com>
> Tested-by: Yaju Cao <yacao@redhat.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> The patch is needed for stable.

Applied and queued up for -stable, thanks Jason.
