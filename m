From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH 03/17] Drivers: hv: kvp: Cleanup error handling in KVP
Date: Wed, 25 Jul 2012 09:59:12 +0200
Message-ID: <20120725075912.GA22443@aepfle.de>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-3-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	apw@canonical.com, netdev@vger.kernel.org, ben@decadent.org.uk
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1343145701-3691-3-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, K. Y. Srinivasan wrote:


> +++ b/drivers/hv/hv_kvp.c
> @@ -48,13 +48,24 @@ static struct {
>  	void *kvp_context; /* for the channel callback */
>  } kvp_transaction;
>  
> +/*
> + * Before we can accept KVP messages from the host, we need
> + * to handshake with the user level daemon. This state tarcks

tracks

> + * if we are in the handshake phase.
> + */

> -		 * Something failed or the we have timedout;
> +		 * Something failed or  we have timedout;

extra space
