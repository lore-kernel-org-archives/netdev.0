From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net] net: fix feature changes on devices without
 ndo_set_features
Date: Fri, 13 Nov 2015 09:06:38 -0500
Message-ID: <20151113140606.GQ12970@gospo.home.greyhouse.net>
References: <5645C0A5.2080506@cumulusnetworks.com>
 <1447422841-2333-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jarod Wilson <jarod@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33469 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719AbbKMOHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 09:07:19 -0500
Received: by oixx65 with SMTP id x65so38232126oix.0
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 06:07:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1447422841-2333-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2015 at 02:54:01PM +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> When __netdev_update_features() was updated to ensure some features are
> disabled on new lower devices, an error was introduced for devices which
> don't have the ndo_set_features() method set. Before we'll just set the
> new features, but now we return an error and don't set them. Fix this by
> returning the old behaviour and setting err to 0 when ndo_set_features
> is not present.

Thanks for the quick turnaround.

> Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
> CC: Jarod Wilson <jarod@redhat.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Ido Schimmel <idosch@mellanox.com>
> CC: Sander Eikelenboom <linux@eikelenboom.it>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Reviewed-by: Andy Gospodarek <gospo@cumulusnetworks.com>
