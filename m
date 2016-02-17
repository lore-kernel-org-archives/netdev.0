From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/9] amd-xgbe: Disable VLAN filtering when
 in promiscuous mode
Date: Tue, 16 Feb 2016 20:19:34 -0500 (EST)
Message-ID: <20160216.201934.2034325737936595643.davem@davemloft.net>
References: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
	<20160212143224.23973.91104.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933275AbcBQBTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:19:36 -0500
In-Reply-To: <20160212143224.23973.91104.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 12 Feb 2016 08:32:24 -0600

> +#ifndef CRCPOLY_LE
> +#define CRCPOLY_LE 0xedb88320
> +#endif
> +static u32 xgbe_vid_crc32_le(__le16 vid_le)

Please do not implement yet another copy of a CRC implementation.

Make use of the various versions the kernel provides already instead,
add Kconfig dependencies as needed.

Thanks.
