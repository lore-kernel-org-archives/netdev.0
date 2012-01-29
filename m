From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: pull request: sfc-next 2012-01-27
Date: Sun, 29 Jan 2012 21:40:05 +0000
Message-ID: <1327873205.5400.383.camel@deadeye>
References: <1327696858.2503.7.camel@bwh-desktop>
	 <20120129.161820.1090236443384833933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11325 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753205Ab2A2VkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 16:40:07 -0500
In-Reply-To: <20120129.161820.1090236443384833933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-01-29 at 16:18 -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 27 Jan 2012 20:40:58 +0000
> 
> > The following changes since commit 9b28ecd66b391349d3492574500f978566195454:
> > 
> >   net: usb: qmi_wwan: New driver for Huawei QMI based WWAN devices (2012-01-25 16:59:47 -0500)
> > 
> > are available in the git repository at:
> >   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> > 
> > (commit db3395697cad6e9dff8d21249e0b59dc9bb83b48)
> > 
> > This is a mixture of cleanup, minor bug fixes, and a few features:
> > 
> > - Increase default number of queues to 1 per core
> > - Add hardware monitor driver for Siena
> 
> Pulled, but two things:
> 
> 1) Please address Joe Perches's feedback, with follow-on patches
>    if necessary.

Will do.

> 2) That DEBUG undef for the sake of mtd.h has to go, I see no use
>    nor even a reference to DEBUG in that header file in the current
>    sources.

Oh that's nice; I'll gladly remove that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
