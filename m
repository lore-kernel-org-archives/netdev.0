From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 6/8] bonding: add arp_ip_target netlink
 support
Date: Fri, 13 Dec 2013 08:30:11 +0100
Message-ID: <20131213073011.GF2486@minipsycho.orion>
References: <20131212221030.21629.81548.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:55587 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab3LMHaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 02:30:14 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so573061eek.27
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 23:30:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131212221030.21629.81548.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 12, 2013 at 11:10:31PM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_ARP_IP_TARGET to allow get/set of bonding parameter
>arp_ip_target via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

>---
> drivers/net/bonding/bond_netlink.c |   36 ++++++++++
> drivers/net/bonding/bond_options.c |  130 ++++++++++++++++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c   |   84 ++++-------------------
> drivers/net/bonding/bonding.h      |    4 +
> include/uapi/linux/if_link.h       |    1 
> 5 files changed, 187 insertions(+), 68 deletions(-)
>
