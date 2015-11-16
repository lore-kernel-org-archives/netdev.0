From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix VLANs null-pointer for 57710, 57711
Date: Mon, 16 Nov 2015 15:13:21 -0500 (EST)
Message-ID: <20151116.151321.1735337274070931231.davem@davemloft.net>
References: <1447592536-15744-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, osbart@redhat.com, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbKPUNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:13:22 -0500
In-Reply-To: <1447592536-15744-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 15 Nov 2015 15:02:16 +0200

> Commit 05cc5a39ddb7 "bnx2x: add vlan filtering offload" introduced
> a regression in regard for vlans for 57710, 57711 adapters -
> Loading 8021q module on a machine with such an adapter would cause
> a null pointer dereference, as the driver mistakenly publishes it
> has capabilities for vlan CTAG filtering.
> 
> Reported-by: Otto Sabart <osabart@redhat.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
