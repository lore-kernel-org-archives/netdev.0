From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-timestamp: document deprecated syststamp
Date: Tue, 15 Jul 2014 16:33:07 -0700 (PDT)
Message-ID: <20140715.163307.45792518982293822.davem@davemloft.net>
References: <1405374930-4763-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760392AbaGOXdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:33:08 -0400
In-Reply-To: <1405374930-4763-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon, 14 Jul 2014 17:55:30 -0400

> The SO_TIMESTAMPING API defines option SOF_TIMESTAMPING_SYS_HW.
> This feature is deprecated. It should not be implemented by new
> device drivers. Existing drivers do not implement it, either --
> with one exception.
> 
> Driver developers are encouraged to expose the NIC hw clock as a
> PTP HW clock source, instead, and synchronize system time to the
> HW source.
> 
> The control flag cannot be removed due to being part of the ABI, nor
> can the structure scm_timestamping that is returned. Due to the one
> legacy driver, the internal datapath and structure are not removed.
> 
> This patch only clearly marks the interface as deprecated. Device
> drivers should always return a syststamp value of zero.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
