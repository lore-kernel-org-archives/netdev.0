From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] net: vrf: Improve use of FIB rules
Date: Mon, 06 Jun 2016 15:47:38 -0700 (PDT)
Message-ID: <20160606.154738.2069568651897544011.davem@davemloft.net>
References: <1464982616-23030-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbcFFWrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 18:47:40 -0400
In-Reply-To: <1464982616-23030-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri,  3 Jun 2016 12:36:54 -0700

> Currently, VRFs require 1 oif and 1 iif rule per address family per
> VRF. As the number of VRF devices increases it brings scalability
> issues with the increasing rule list. All of the VRF rules have the
> same format with the exception of the specific table id to direct the
> lookup. Since the table id is available from the oif or iif in the
> loopup, the VRF rules can be consolidated to a single rule that pulls
> the table from the VRF device.
> 
> This solution still allows a user to insert their own rules for VRFs,
> including rules with additional attributes. Accordingly, it is backwards
> compatible with existing setups and allows other policy routing as
> desired.

I hate module parameters.

And you don't even need one in this situation, just use a default preference
of 1000 and add a newlink netlink attribute that can change it.

Thanks.
