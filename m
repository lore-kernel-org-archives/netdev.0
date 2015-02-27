From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix PCI-E Memory window interface for
 big-endian systems
Date: Fri, 27 Feb 2015 15:59:11 -0500 (EST)
Message-ID: <20150227.155911.683029385758928369.davem@davemloft.net>
References: <1424863204-12580-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbbB0U7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:59:13 -0500
In-Reply-To: <1424863204-12580-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 25 Feb 2015 16:50:04 +0530

> When doing reads and writes to adapter memory via the PCI-E Memory Window
> interface, data gets swizzled on 4-byte boundaries on Big-Endian systems
> because we need to account for the register read/write interface which
> incorporates a swizzle onto the Little-Endian PCI-E Bus.
> 
> Based on original work by Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
