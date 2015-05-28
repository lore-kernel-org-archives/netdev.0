From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net-next 1/1] hv_netvsc: Properly size the vrss queues
Date: Thu, 28 May 2015 10:06:13 +0300
Message-ID: <20150528070613.GV11588@mwanda>
References: <1432682469-15033-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 davem@davemloft.net
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1432682469-15033-1-git-send-email-kys@microsoft.com>
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

Since you're redoing this anyway.

On Tue, May 26, 2015 at 04:21:09PM -0700, K. Y. Srinivasan wrote:
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index ddcc7f8..dd45440 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -161,6 +161,7 @@ struct netvsc_device_info {
>  	unsigned char mac_adr[ETH_ALEN];
>  	bool link_state;	/* 0 - link up, 1 - link down */
>  	int  ring_size;
> +	u32  max_num_vrss_chns;

We (Joe and I) have commented before that long names don't mix well with
the 80 character limit.  You could just leave the "num_" out.  Almost
all variables are numbers in C so it doesn't add anything.

regards,
dan carpenter
