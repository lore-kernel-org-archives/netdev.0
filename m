From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] 8139cp: reset BQL when ring tx ring cleared
Date: Mon, 20 May 2013 14:03:04 -0700 (PDT)
Message-ID: <20130520.140304.1559992481567867338.davem@davemloft.net>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550Ab3ETVDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 17:03:05 -0400
In-Reply-To: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 20 May 2013 09:54:43 -0700

> This patch cures transmit timeout's with DHCP observed
> while running under KVM. When the transmit ring is cleaned out,
> the Byte Queue Limit values need to be reset.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
