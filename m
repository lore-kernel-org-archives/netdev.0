From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH v2] net: smsc: smc91x: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 05 Mar 2017 14:47:00 +0100
Message-ID: <87bmtfx2cr.fsf@belgarion.home>
References: <1488627759-8717-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nico@fluxnic.net, davem@davemloft.net, mugunthanvnm@ti.com,
        jarod@redhat.com, felipe.balbi@linux.intel.com,
        rmk+kernel@armlinux.org.uk, fw@strlen.de, jeremy.linton@arm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp09.smtpout.orange.fr ([80.12.242.131]:27242 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752290AbdCEOT2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 09:19:28 -0500
In-Reply-To: <1488627759-8717-1-git-send-email-tremyfr@gmail.com> (Philippe
        Reynes's message of "Sat, 4 Mar 2017 12:42:39 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philippe Reynes <tremyfr@gmail.com> writes:

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - also update comment (feeback from Russel King)

Ok, I tested it, with :
    ethtool -s eth0 duplex half autoneg off speed 10
    ethtool eth0
       => see the changes
    ping -f x.x.x.x
    ethtool -s eth0 duplex full autoneg on
    ethtool eth0
       => see the changes
    ping -f x.x.x.x

This both with your patch and without, it works in both cases, and the former as
a smaller throughput, which makes me believe the patch is fine.

Tested-by: Robert Jarzmik <robert.jarzmik@free.fr>

Cheers.
