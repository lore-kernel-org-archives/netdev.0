From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH] xen-netfront: report link speed to ethtool
Date: Fri, 18 Nov 2011 19:43:36 +0100
Message-ID: <20111118184336.GA16027@aepfle.de>
References: <20111118164805.GA14345@aepfle.de>
 <1321638394.2883.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:65093 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163Ab1KRSnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 13:43:46 -0500
Content-Disposition: inline
In-Reply-To: <1321638394.2883.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, Ben Hutchings wrote:

> On Fri, 2011-11-18 at 17:48 +0100, Olaf Hering wrote:
> > The reported data refers to VMWare vmxnet.
> NAK, we should not just make things up.

So how about removing veth_get_settings, vmxnet3_get_settings,
tun_get_settings and other functions that escaped my grep?

Olaf
