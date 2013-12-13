From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 2/8] bonding: add updelay netlink support
Date: Fri, 13 Dec 2013 08:29:14 +0100
Message-ID: <20131213072914.GB2486@minipsycho.orion>
References: <20131212221002.21629.240.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:43309 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab3LMH3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 02:29:16 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so671329ead.6
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 23:29:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131212221002.21629.240.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 12, 2013 at 11:10:02PM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_UPDELAY to allow get/set of bonding parameter
>updelay via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

>---
> drivers/net/bonding/bond_netlink.c |   13 +++++++++++
> drivers/net/bonding/bond_options.c |   29 +++++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c   |   42 +++++++++---------------------------
> drivers/net/bonding/bonding.h      |    1 +
> include/uapi/linux/if_link.h       |    1 +
> 5 files changed, 54 insertions(+), 32 deletions(-)
>
