From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] enic: add adaptive coalescing intr for
 intx and msi poll
Date: Mon, 20 Jul 2015 12:39:40 -0700 (PDT)
Message-ID: <20150720.123940.1427684038846767257.davem@davemloft.net>
References: <1436954680-10248-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754048AbbGTTjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:39:46 -0400
In-Reply-To: <1436954680-10248-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 15 Jul 2015 15:34:39 +0530

> Adaptive interrupt coalescing is available for msix. This patch adds the support
> for msi poll. Interface for adaptive interrupt coalescing is already added in
> driver. We just did not enable it for legacy intr & msi.
> 
> enic_calc_int_moderation() & enic_set_int_moderation() are defined as static
> after enic_poll. Since enic_poll needs it, move both of these function
> definitions above enic_poll. No change in functionality.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
