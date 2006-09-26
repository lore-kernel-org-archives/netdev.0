From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB
 devices
Date: Tue, 26 Sep 2006 10:05:35 -0700
Message-ID: <20060926100535.7cde2de2@freekitty>
References: <Pine.LNX.4.64.0609261309540.24189@zuben>
	<Pine.LNX.4.64.0609261317460.24189@zuben>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:38809 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932112AbWIZRFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 13:05:49 -0400
To: Or Gerlitz <ogerlitz@voltaire.com>
In-Reply-To: <Pine.LNX.4.64.0609261317460.24189@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Sep 2006 13:18:09 +0300 (IDT)
Or Gerlitz <ogerlitz@voltaire.com> wrote:

> Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
> 
> Index: net-2.6.19/drivers/net/bonding/bond_main.c
> ===================================================================
> --- net-2.6.19.orig/drivers/net/bonding/bond_main.c	2006-09-25 11:46:35.000000000 +0300
> +++ net-2.6.19/drivers/net/bonding/bond_main.c	2006-09-26 10:54:44.000000000 +0300
> @@ -128,6 +128,12 @@ MODULE_PARM_DESC(arp_interval, "arp inte
>  module_param_array(arp_ip_target, charp, NULL, 0);
>  MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
> 
> +static int bonding_dev_type    = ARPHRD_ETHER;
> +static int bonding_dev_addrlen = ETH_ALEN;
> +
> +module_param(bonding_dev_type,    int, 0644);
> +module_param(bonding_dev_addrlen, int, 0644);

Do you really want to allow changing these values after module load?
If not replace 0644 with 0
