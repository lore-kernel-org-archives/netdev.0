From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH/RFC] can: mcp251x: Allow pass IRQ flags through
	platform data.
Date: Wed, 6 Apr 2011 09:14:57 +0200
Message-ID: <20110406071457.GC284@kurt.e-circ.dyndns.org>
References: <1302023321-25182-1-git-send-email-eballetbo@iseebcn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: Enric Balletbo i Serra <eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1302023321-25182-1-git-send-email-eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2011 at 07:08:41PM +0200, Enric Balletbo i Serra wrote:
>  	ret = request_threaded_irq(spi->irq, NULL, mcp251x_can_ist,
> -			  IRQF_TRIGGER_FALLING, DEVICE_NAME, priv);
> +		  pdata->irq_flags ? pdata->irq_flags : IRQF_TRIGGER_FALLING,
> +		  DEVICE_NAME, priv);

IMHO, doing like this looks just a tiny bit cleaner
> +		  pdata->irq_flags ?: IRQF_TRIGGER_FALLING,
> +		  DEVICE_NAME, priv);

That's really the only remark :-)

Regards,
Kurt
