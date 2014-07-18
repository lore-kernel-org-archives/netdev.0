From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Fri, 18 Jul 2014 15:43:06 +0530
Message-ID: <53C8F332.8010604@gmail.com>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: huishao@microsoft.com, haiyangz@microsoft.com
To: Yue Zhang <yuezha@microsoft.com>, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org, olaf@aepfle.de, jasowang@redhat.com,
 davem@davemloft.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
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

On 07/18/2014 04:25 PM, Yue Zhang wrote:
> @@ -816,8 +816,21 @@ static void netvsc_link_change(struct work_struct *w)
>   
>   	rtnl_unlock();
>   
> -	if (refresh)
> -		call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
> +	if (refresh) {
> +		/*
> +		 * Keep the carrier offline for 10 seconds
> +		 * to notify ifplugd daemon network change
> +		 */

This should be networking comment style..

	/* bla bla..
	 * bla
	 */

-- 
Regards,
Varka Bhadram.
