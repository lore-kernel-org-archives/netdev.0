From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw
 implementation
Date: Tue, 1 Dec 2015 15:43:00 +0100
Message-ID: <20151201144300.GB2165@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, pjonnala@broadcom.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:32816 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755608AbbLAOnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 09:43:03 -0500
Received: by wmec201 with SMTP id c201so208683646wme.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 06:43:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 01, 2015 at 02:48:38PM CET, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>This patchset introduces needed infrastructure for link aggregation
>offload - for both team and bonding. It also implements the offload
>in mlxsw driver.
>
>Particulary, this patchset introduces possibility for upper driver
>(bond/team/bridge/..) to pass type-specific info down to notifier listeners.
>Info is passed along with NETDEV_CHANGEUPPER/NETDEV_PRECHANGEUPPER
>notifiers. Listeners (drivers of netdevs being enslaved) can react
>accordingly.
>
>Other extension is for run-time use. This patchset introduces
>new netdev notifier type - NETDEV_CHANGELOWERSTATE. Along with this
>notification, the upper driver (bond/team/bridge/..) can pass some
>information about lower device change, particulary link-up and
>TX-enabled states. Listeners (drivers of netdevs being enslaved)
>can react accordingly.
>
>The last part of the patchset is implementation of LAG offload in mlxsw,
>using both previously introduced infrastructre extensions.
>
>Note that bond-speficic (and ugly) NETDEV_BONDING_INFO used by mlx4
>can be removed and mlx4 can use the extensions this patchset adds.
>I plan to convert it and get rid of NETDEV_BONDING_INFO in
>a follow-up patchset.

ccing couple of people I forgot to cc.
