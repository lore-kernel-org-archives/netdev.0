From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [RFC][PATCH V2 1/3] enable bonding to enslave non ARPHRD_ETHER
 netdevices
Date: Thu, 30 Nov 2006 13:09:42 +0200
Message-ID: <456EBBF6.3070802@voltaire.com>
References: <Pine.LNX.4.64.0611301256130.26156@zuben> <Pine.LNX.4.64.0611301256530.26156@zuben>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, Roland Dreier <rdreier@cisco.com>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:3549 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S936072AbWK3LJv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 06:09:51 -0500
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0611301256530.26156@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz wrote:
> Index: net-2.6.20/drivers/net/bonding/bonding.h
> ===================================================================
> --- net-2.6.20.orig/drivers/net/bonding/bonding.h	2006-11-30 10:54:23.000000000 +0200
> +++ net-2.6.20/drivers/net/bonding/bonding.h	2006-11-30 10:58:10.000000000 +0200
> @@ -201,6 +201,7 @@ struct bonding {
>  	struct   list_head vlan_list;
>  	struct   vlan_group *vlgrp;
>  	struct   packet_type arp_mon_pt;
> +	s8       do_set_mac_addr;
>  };
> 
>  /**

oops - this piece belongs to the second patch, which actually uses the 
added field, sorry for that. I will fix it for the next version.

Or.

