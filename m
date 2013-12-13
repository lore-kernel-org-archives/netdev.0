From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/8] bonding: add miimon netlink support
Date: Fri, 13 Dec 2013 08:28:56 +0100
Message-ID: <20131213072856.GA2486@minipsycho.orion>
References: <20131212220955.21629.17005.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:33208 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab3LMH3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 02:29:00 -0500
Received: by mail-ee0-f45.google.com with SMTP id d49so658575eek.18
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 23:28:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131212220955.21629.17005.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 12, 2013 at 11:09:55PM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_MIIMON to allow get/set of bonding parameter
>miimon via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

>---
> drivers/net/bonding/bond_netlink.c |   32 ++++++++++++++++++----
> drivers/net/bonding/bond_options.c |   42 +++++++++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c   |   53 +++++++-----------------------------
> drivers/net/bonding/bonding.h      |    1 +
> include/uapi/linux/if_link.h       |    1 +
> 5 files changed, 80 insertions(+), 49 deletions(-)
>
