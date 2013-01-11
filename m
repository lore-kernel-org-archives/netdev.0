From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] net: Export __netdev_pick_tx so that it can be used in
 modules
Date: Fri, 11 Jan 2013 11:02:17 -0800
Message-ID: <50F061B9.4060703@intel.com>
References: <20130111183842.6152.34578.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:58762 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab3AKTCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 14:02:17 -0500
In-Reply-To: <20130111183842.6152.34578.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/11/2013 10:38 AM, Alexander Duyck wrote:
> When testing with FCoE enabled we discovered that I had not exported
> __netdev_pick_tx.  As a result ixgbe doesn't build with the RFC patches
> applied because ixgbe_select_queue was calling the function.  This change
> corrects that build issue by correctly exporting __netdev_pick_tx so it
> can be used by modules.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

Hi Alex,

If we get XPS to play nicely with the traffic class schemes we
can just remove select_queue completely.

I'll take a look tomorrow.

Thanks,
John
