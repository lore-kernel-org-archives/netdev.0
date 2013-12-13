From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 5/8] bonding: add arp_interval netlink support
Date: Fri, 13 Dec 2013 08:29:58 +0100
Message-ID: <20131213072958.GE2486@minipsycho.orion>
References: <20131212221023.21629.65304.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:65414 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab3LMHaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 02:30:01 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so663737eaj.35
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 23:30:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131212221023.21629.65304.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 12, 2013 at 11:10:24PM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_ARP_INTERVAL to allow get/set of bonding parameter
>arp_interval via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

>---
> drivers/net/bonding/bond_netlink.c |   21 ++++++++++++
> drivers/net/bonding/bond_options.c |   47 ++++++++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c   |   61 ++++++------------------------------
> drivers/net/bonding/bonding.h      |    1 +
> include/uapi/linux/if_link.h       |    1 +
> 5 files changed, 80 insertions(+), 51 deletions(-)
>
