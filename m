From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 07 Jul 2015 11:37:56 +0200
Message-ID: <1436261876.20057.132.camel@tiscali.nl>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	haiyangz@microsoft.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436194049-27829-1-git-send-email-decui@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just two nits.

On ma, 2015-07-06 at 07:47 -0700, Dexuan Cui wrote:
> --- /dev/null
> +++ b/net/hv_sock/Kconfig

> +config HYPERV_SOCK
> +	tristate "Microsoft Hyper-V Socket (EXPERIMENTAL)"
> +	depends on HYPERV
> +	default m
> +	help
> +	  Hyper-V Socket is a socket protocol similar to TCP, allowing
> +	  communication between a Linux guest and the host.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called hv_sock. If unsure, say N.

It's a bit odd to advise to say N if one is unsure and set the default
to 'm' at the same time.

> --- /dev/null
> +++ b/net/hv_sock/af_hvsock.c

> +static int hvsock_init(void)
> +{
> +	[...]
> +}
> +
> +static void hvsock_exit(void)
> +{
> +	[...]
> +}
> +
> +module_init(hvsock_init);
> +module_exit(hvsock_exit);

Any specific reason not to mark these functions __init and __exit?

Thanks,


Paul Bolle
