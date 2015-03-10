From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] net: fec: fix receive VLAN CTAG HW
 acceleration issue
Date: Tue, 10 Mar 2015 12:42:40 -0400 (EDT)
Message-ID: <20150310.124240.1163492906111984968.davem@davemloft.net>
References: <1425985781-25736-1-git-send-email-b38611@freescale.com>
	<20150310114102.GB22614@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: mgr@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbbCJQmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 12:42:42 -0400
In-Reply-To: <20150310114102.GB22614@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <mgr@pengutronix.de>
Date: Tue, 10 Mar 2015 12:41:02 +0100

> On Tue, Mar 10, 2015 at 07:09:41PM +0800, Fugang Duan wrote:
>> The current driver support receive VLAN CTAG HW acceleration feature
>> (NETIF_F_HW_VLAN_CTAG_RX) through software simulation. There calls the
>> api .skb_copy_to_linear_data_offset() to skip the VLAN tag, but there
>> have overlap between the two memory data point range. The patch just fix
>> the issue.
>> 
>> V2:
>> Michael Grzeschik suggest to use memmove() instead of skb_copy_to_linear_data_offset().
> 
> This probably is not welcome in the patch description.

Why not?  Changelogs aid in understanding how a final commit got to
be the way it was, and it gives credit to people who suggest changes.

> How about?
> 
> Cc: <stable@vger.kernel.org> # back to commit 1b7bde6d6

Nope.

If indeed it is valid for -stable, I handle all networking -stable
submissions by hand rather than via the stable CC: mechanism.
Therefore the patch submitter simply has to ask me to queue the change
up for -stable.
