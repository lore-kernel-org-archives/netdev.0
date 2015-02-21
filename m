From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 0/2] dsa: implement HW bonding
Date: Sat, 21 Feb 2015 17:40:42 +0100
Message-ID: <20150221164042.GD2092@nanopsycho.orion>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>
To: Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:38426 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbBUQkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 11:40:47 -0500
Received: by mail-wg0-f46.google.com with SMTP id a1so18373880wgh.5
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 08:40:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 20, 2015 at 11:51:11AM CET, jonasj76@gmail.com wrote:
>From: Jonas Johansson <jonas.johansson@westermo.se>
>
>This patchset will implement hardware bonding support for the DSA driver and
>the Marvell 88E6095 device.
>
>Jonas Johansson (2):
>  dsa: bonding: implement HW bonding
>  mv88e6131: bonding: implement single device trunking
>

You should use scripts/get_maintainer.pl script and cc all relevant
people...


> drivers/net/dsa/mv88e6131.c | 254 ++++++++++++++++++++++++++++++++++++++++++++
> drivers/net/dsa/mv88e6xxx.h |  14 +++
> drivers/net/team/team.c     |   4 +
> include/linux/netdevice.h   |   8 ++
> include/net/dsa.h           |   8 ++
> net/dsa/dsa.c               |  60 +++++++++++
> net/dsa/dsa_priv.h          |   6 ++
> net/dsa/slave.c             |  23 ++++
> 8 files changed, 377 insertions(+)
>
>-- 
>2.1.0
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
