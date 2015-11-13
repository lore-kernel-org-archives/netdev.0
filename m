From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: fix feature changes on devices without
 ndo_set_features
Date: Fri, 13 Nov 2015 15:00:25 +0100
Message-ID: <20151113140025.GC2143@nanopsycho.orion>
References: <5645C0A5.2080506@cumulusnetworks.com>
 <1447422841-2333-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jarod Wilson <jarod@redhat.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36467 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669AbbKMOA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 09:00:29 -0500
Received: by wmww144 with SMTP id w144so29835805wmw.1
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 06:00:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1447422841-2333-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 13, 2015 at 02:54:01PM CET, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>When __netdev_update_features() was updated to ensure some features are
>disabled on new lower devices, an error was introduced for devices which
>don't have the ndo_set_features() method set. Before we'll just set the
>new features, but now we return an error and don't set them. Fix this by
>returning the old behaviour and setting err to 0 when ndo_set_features
>is not present.
>
>Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
>CC: Jarod Wilson <jarod@redhat.com>
>CC: Jiri Pirko <jiri@resnulli.us>
>CC: Ido Schimmel <idosch@mellanox.com>
>CC: Sander Eikelenboom <linux@eikelenboom.it>
>CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>CC: Florian Fainelli <f.fainelli@gmail.com>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Thanks.
