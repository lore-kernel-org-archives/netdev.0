From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 0/7] Fix sti drivers whcih mix reg address spaces
Date: Mon, 01 Dec 2014 16:36:51 +0100
Message-ID: <8237128.RmunIxMfYX@wuerfel>
References: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	srinivas.kandagatla-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, maxime.coquelin-qxv4g6HH51o@public.gmane.org,
	patrice.chotard-qxv4g6HH51o@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org, kishon-l0cyMroinI0@public.gmane.org,
	lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org
To: Peter Griffin <peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416385632-5832-1-git-send-email-peter.griffin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 November 2014 08:27:05 Peter Griffin wrote:
> Hi,
> 
> Following on from Arnds comments about the picophy driver here
> https://lkml.org/lkml/2014/11/13/161, this series fixes the
> remaining upstreamed drivers for STI, which are mixing address spaces
> in the reg property. We do this in a way similar to the keystone
> and bcm7445 platforms, by having sysconfig phandle/ offset pair (
> where only one register is required). Or phandle / integer array
> where multiple offsets in the same bank are needed).
> 
> This series breaks DT compatability! But the platform support
> is WIP and only being used by the few developers who are upstreaming
> support for it. I've made each change to the driver / dt doc / dt
> file as a single atomic commit so the kernel will remain bisectable. 
> 
> This series then also enables the picophy driver, and adds back in
> the ehci/ohci dt nodes for stih410 which make use of the picophy.

This all looks very good to me, nice work!

Reviewed-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

I have one comment for patch 4, but I don't have a good solution for
that, hopefully someone on the devicetree-discuss list has some insight,
otherwise we just keep your version.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
