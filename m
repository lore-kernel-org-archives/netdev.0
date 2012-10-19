From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v1] net/core: support runtime PM on net_device
Date: Fri, 19 Oct 2012 09:45:04 +0800
Message-ID: <CACVXFVNXFEg0kiFb6RGfS9grYvyuRL-=jiqEdxDEnn0Avwpw9Q@mail.gmail.com>
References: <1350548469-1267-1-git-send-email-ming.lei@canonical.com>
	<8762689o9u.fsf@nemi.mork.no>
	<CACVXFVPu1m3CJaFavW9eaU3Z850q+x1N_Yo7tri1UTFpgfYVXQ@mail.gmail.com>
	<87obk080us.fsf@nemi.mork.no>
	<CACVXFVMmSFHYU-sNHRM7g_8U6mjbdbE+bNPxM-F8iAB=4WudRA@mail.gmail.com>
	<50802F8A.6090205@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:58900 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756991Ab2JSBpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 21:45:06 -0400
In-Reply-To: <50802F8A.6090205@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 12:34 AM, Daniel Lezcano
<daniel.lezcano@linaro.org> wrote:
> Hi Ming,
>
> IIUC, the pm_runtime is related to the device drivers, so at the first
> glance, we should see invocation of the runtime's functions in drivers/*
> and arch/*. Adding these calls in the net core, which makes sense at a
> certain point, is a bit weird for me.
>
> From my POV, if the drivers have been modified to support the pm_runtime
> and this new functionality brought a regression with the ioctl, that
> should be fixed in the drivers and not in the core code.
>
> What happens with your patch if we use ethtool on a virtual device like
> veth, macvlan, bridge, ... ?

No any effect no matter if these drivers implement runtime PM or not.


Thanks,
--
Ming Lei
