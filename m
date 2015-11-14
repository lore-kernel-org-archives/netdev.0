From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Sat, 14 Nov 2015 10:39:20 +0100
Message-ID: <20151114093920.GA2188@nanopsycho.orion>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, andrew@lunn.ch,
	f.fainelli@gmail.com, idosch@mellanox.com,
	nikolay@cumulusnetworks.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34528 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbbKNJjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 04:39:23 -0500
Received: by wmvv187 with SMTP id v187so113326195wmv.1
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2015 01:39:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 12, 2015 at 05:02:18PM CET, pjonnala@broadcom.com wrote:
>Packet forwarding to/from bond interfaces is done in software.
>
>This patch enables certain platforms to bridge traffic to/from
>bond interfaces in hardware.  Notifications are sent out when 
>the "active" slave set for a bond interface is updated in 
>software.  Platforms use the notifications to program the 
>hardware accordingly.  The changes have been verified to work 
>with configured and 802.3ad bond interfaces.
>
>Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>

This patch is wrong, in many different acpects. Leaving the submission
style, and no in-tree consumer aside, adding ndos for this thing is
unacceptable. It should be handled as a part of switchdev attrs.
Also, the solution should not be bonding-centric.

I have a patchset in my queue which does this correctly, for bond and team
using switchdev attr and with actual in-tree consumer, mlxsw driver.
I plan to send that soon after net-next opens.

Jiri
