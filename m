From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: Fix ARP monitor validation
Date: Fri, 29 Jan 2016 20:07:53 -0800 (PST)
Message-ID: <20160129.200753.416219877672699488.davem@davemloft.net>
References: <16766.1454031188@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710AbcA3EH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 23:07:56 -0500
In-Reply-To: <16766.1454031188@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Thu, 28 Jan 2016 17:33:08 -0800

> +	else if (curr_arp_slave && (arp->ar_op == htons(ARPOP_REPLY)) &&
> +		 bond_time_in_interval(bond,
> +				       dev_trans_start(curr_arp_slave->dev), 1))
> +		bond_validate_arp(bond, slave, sip, tip);

Please document this timeout condition, both in your commit message and in
the "We 'trust' the arp requests..." comment.

Thanks.
