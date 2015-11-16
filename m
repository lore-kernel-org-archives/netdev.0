From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix feature changes on devices without
 ndo_set_features
Date: Mon, 16 Nov 2015 14:56:35 -0500 (EST)
Message-ID: <20151116.145635.1625494915754780979.davem@davemloft.net>
References: <5645C0A5.2080506@cumulusnetworks.com>
	<1447422841-2333-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	jarod@redhat.com, jiri@resnulli.us, idosch@mellanox.com,
	linux@eikelenboom.it, gospo@cumulusnetworks.com,
	f.fainelli@gmail.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbbKPT4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:56:37 -0500
In-Reply-To: <1447422841-2333-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 13 Nov 2015 14:54:01 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> When __netdev_update_features() was updated to ensure some features are
> disabled on new lower devices, an error was introduced for devices which
> don't have the ndo_set_features() method set. Before we'll just set the
> new features, but now we return an error and don't set them. Fix this by
> returning the old behaviour and setting err to 0 when ndo_set_features
> is not present.
> 
> Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
> CC: Jarod Wilson <jarod@redhat.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Ido Schimmel <idosch@mellanox.com>
> CC: Sander Eikelenboom <linux@eikelenboom.it>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
