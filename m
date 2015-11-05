From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix prefsrc lookups
Date: Wed, 04 Nov 2015 21:35:09 -0500 (EST)
Message-ID: <20151104.213509.738680895043467025.davem@davemloft.net>
References: <1446595168-27323-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladi@aresgate.net
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030897AbbKECfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 21:35:11 -0500
In-Reply-To: <1446595168-27323-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue,  3 Nov 2015 15:59:28 -0800

> A bug report (https://bugzilla.kernel.org/show_bug.cgi?id=107071) noted
> that the follwoing ip command is failing with v4.3:
> 
>     $ ip route add 10.248.5.0/24 dev bond0.250 table vlan_250 src 10.248.5.154
>     RTNETLINK answers: Invalid argument
> 
> 021dd3b8a142d changed the lookup of the given preferred source address to
> use the table id passed in, but this assumes the local entries are in the
> given table which is not necessarily true for non-VRF use cases. When
> validating the preferred source fallback to the local table on failure.
> 
> Fixes: 021dd3b8a142d ("net: Add routes to the table associated with the device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
