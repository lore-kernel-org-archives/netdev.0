From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bonding: Prevent IPv6 link local address on
 enslaved devices
Date: Mon, 11 Jan 2016 17:57:06 -0500 (EST)
Message-ID: <20160111.175706.904376751900870814.davem@davemloft.net>
References: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: kheiss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933349AbcAKW5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 17:57:09 -0500
In-Reply-To: <1452518923-9420-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Heiss <kheiss@gmail.com>
Date: Mon, 11 Jan 2016 08:28:43 -0500

> Commit 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
> undoes the fix provided by commit c2edacf80e15 ("bonding / ipv6: no addrconf
> for slaves separately from master") by effectively setting the slave flag
> after the slave has been opened.  If the slave comes up quickly enough, it
> will go through the IPv6 addrconf before the slave flag has been set and
> will get a link local IPv6 address.
> 
> In order to ensure that addrconf knows to ignore the slave devices on state
> change, set IFF_SLAVE before dev_open() during bonding enslavement.
> 
> Fixes: 1f718f0f4f97 ("bonding: populate neighbour's private on enslave")
> 
> Signed-off-by: Karl Heiss <kheiss@gmail.com>

Applied and queued up for -stable, thanks.
