From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 7/8] bonding: add arp_validate netlink support
Date: Fri, 13 Dec 2013 08:30:26 +0100
Message-ID: <20131213073026.GG2486@minipsycho.orion>
References: <20131212221038.21629.75257.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:40035 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab3LMHa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 02:30:29 -0500
Received: by mail-ee0-f44.google.com with SMTP id b57so674862eek.3
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 23:30:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131212221038.21629.75257.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 12, 2013 at 11:10:38PM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_ARP_VALIDATE to allow get/set of bonding parameter
>arp_validate via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

>---
> drivers/net/bonding/bond_netlink.c |   18 ++++++++++++++++++
> drivers/net/bonding/bond_options.c |   22 ++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c   |   30 ++++++++----------------------
> drivers/net/bonding/bonding.h      |    1 +
> include/uapi/linux/if_link.h       |    1 +
> 5 files changed, 50 insertions(+), 22 deletions(-)
>
