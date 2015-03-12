From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 1/3 net-next] Drivers: hv: vmbus: Export the
 vmbus_sendpacket_pagebuffer_ctl()
Date: Thu, 12 Mar 2015 10:59:10 +0800
Message-ID: <1426129150.12154.1@smtp.corp.redhat.com>
References: <1426100635-9508-1-git-send-email-kys@microsoft.com>
 <1426100660-9547-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org, apw@canonical.com, devel@linuxdriverproject.org,
 davem@davemloft.net
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1426100660-9547-1-git-send-email-kys@microsoft.com>
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



On Thu, Mar 12, 2015 at 3:04 AM, K. Y. Srinivasan <kys@microsoft.com> 
wrote:
> Export the vmbus_sendpacket_pagebuffer_ctl() interface. This interface
> will be used in the netvsc driver to optimize signalling the host.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/hv/channel.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
> index da53180..e58cdb7 100644
> --- a/drivers/hv/channel.c
> +++ b/drivers/hv/channel.c
> @@ -710,6 +710,7 @@ int vmbus_sendpacket_pagebuffer_ctl(struct 
> vmbus_channel *channel,
>  
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(vmbus_sendpacket_pagebuffer_ctl);
>  
>  /*
>   * vmbus_sendpacket_pagebuffer - Send a range of single-page buffer
> -- 
> 1.7.4.1

Acked-by: Jason Wang <jasowang@redhat.com>
