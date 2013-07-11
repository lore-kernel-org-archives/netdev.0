From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 1/2] vxlan fdb replace an existing entry
Date: Thu, 11 Jul 2013 10:26:02 -0400
Message-ID: <OF5FD8045A.BD5B4AD2-ON85257BA5.004E2C18-85257BA5.004F49E1@us.ibm.com>
References: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>
To: Thomas Richter <tmricht@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:40370 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774Ab3GKO3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 10:29:16 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 11 Jul 2013 08:28:54 -0600
In-Reply-To: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 07/11/2013 06:28:19 AM:

> Multicast mac addresses can not be changed with the replace
> option.

Why not? Although you can't update multiple destinations,
a multicast entry need not have multiple destinations, and
it would also be reasonable to replace a list with a single
destination. I think all you need to do is delete anything after the
first item and remove the check for multicast.

> @@ -42,7 +42,7 @@
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
> 
> -#define VXLAN_VERSION   "0.1"
> +#define VXLAN_VERSION   "0.1tmr3"

You should remove this, of course.

                                        +-DLS
