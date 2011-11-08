From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [SMSC75xx] Fix incorrect usage of NET_IP_ALIGN
Date: Tue, 08 Nov 2011 12:37:42 -0500 (EST)
Message-ID: <20111108.123742.107320764431852874.davem@davemloft.net>
References: <1320773440-30122-1-git-send-email-ne@erfurth.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, stable@vger.kernel.org,
	steve.glendinning@smsc.com
To: ne@erfurth.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755537Ab1KHRjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 12:39:04 -0500
In-Reply-To: <1320773440-30122-1-git-send-email-ne@erfurth.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nico Erfurth <ne@erfurth.eu>
Date: Tue,  8 Nov 2011 18:30:40 +0100

> The driver used NET_IP_ALIGN to remove some additional padding inside of
> the rx_fixup function. On many architectures NET_IP_ALIGN defaults to 2
> which removed the correct amount of bytes.
> 
> On MCORE2-machines commit ea812ca1b06113597adcd8e70c0f84a413d97544
> introduces a change which sets NET_IP_ALIGN to 0 by default. Which
> triggered the bug on these machines.
> 
> This fix introduces a new RXW_PADDING define and uses this instead of
> NET_IP_ALIGN. The name was taken from the original SMSC7500 driver which
> is provided by SMSC.
> 
> Signed-off-by: Nico Erfurth <ne@erfurth.eu>
> Tested-by: Phil Sutter <phil@nwl.cc>

Applied.
