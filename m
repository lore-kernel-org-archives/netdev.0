From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 3/6] Drivers: net: hyperv: Enable offloads on the host
Date: Thu, 6 Mar 2014 22:36:55 +0300
Message-ID: <20140306193655.GL26722@mwanda>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-3-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 davem@davemloft.net
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1394104390-23477-3-git-send-email-kys@microsoft.com>
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

On Thu, Mar 06, 2014 at 03:13:07AM -0800, K. Y. Srinivasan wrote:
> +	offload_params = (struct ndis_offload_params *)((ulong)set +
> +				set->info_buf_offset);

It's a bit simpler to do pointer math like this:

	offload_params = (void *)set + set->info_buf_offset;

regards,
dan carpenter
