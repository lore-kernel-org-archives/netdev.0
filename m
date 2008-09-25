From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/2] drivers/net/bonding: sparse fixes for exported tables
Date: Wed, 24 Sep 2008 22:15:00 -0400
Message-ID: <48DAF424.2060808@garzik.org>
References: <20080914155611.272940975@fluff.org.uk> <20080914155714.793765032@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55402 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbYIYCPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:15:04 -0400
In-Reply-To: <20080914155714.793765032@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks wrote:
> The following sparse warnings are being generated
> because bonding.h is missing definitons for items
> declared in bond_main.c but also used in bond_sysfs.h
> 
> Also export bond_dev_list as this is also declared
> in bond_main but used elsewhere in drivers/net/bonding.
> 
> bond_main.c:105:20: warning: symbol 'bonding_defaults' was not declared. Should it be static?
> bond_main.c:148:1: warning: symbol 'bond_dev_list' was not declared. Should it be static?
> bond_main.c:162:22: warning: symbol 'bond_lacp_tbl' was not declared. Should it be static?
> bond_main.c:168:22: warning: symbol 'bond_mode_tbl' was not declared. Should it be static?
> bond_main.c:179:22: warning: symbol 'xmit_hashtype_tbl' was not declared. Should it be static?
> bond_main.c:186:22: warning: symbol 'arp_validate_tbl' was not declared. Should it be static?
> bond_main.c:194:22: warning: symbol 'fail_over_mac_tbl' was not declared. Should it be static?
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> 
> Index: linux-git-test-next-cats/drivers/net/bonding/bonding.h
> ===================================================================
> --- linux-git-test-next-cats.orig/drivers/net/bonding/bonding.h	2008-09-14 16:39:30.000000000 +0100
> +++ linux-git-test-next-cats/drivers/net/bonding/bonding.h	2008-09-14 16:44:24.000000000 +0100
> @@ -333,5 +333,13 @@ void bond_change_active_slave(struct bon
>  void bond_register_arp(struct bonding *);
>  void bond_unregister_arp(struct bonding *);
>  
> +/* exported from bond_main.c */
> +extern struct list_head bond_dev_list;
> +extern struct bond_parm_tbl bond_lacp_tbl[];
> +extern struct bond_parm_tbl bond_mode_tbl[];
> +extern struct bond_parm_tbl xmit_hashtype_tbl[];
> +extern struct bond_parm_tbl arp_validate_tbl[];
> +extern struct bond_parm_tbl fail_over_mac_tbl[];

applied

patch #2 failed to apply


