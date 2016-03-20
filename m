From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] flowi6_tos fixes
Date: Sun, 20 Mar 2016 13:44:51 -0400 (EDT)
Message-ID: <20160320.134451.139038163148437212.davem@davemloft.net>
References: <cover.1458320940.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, linville@tuxdriver.com, jesse@kernel.org,
	dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcCTRox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 13:44:53 -0400
In-Reply-To: <cover.1458320940.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 18 Mar 2016 18:37:56 +0100

> This set is a follow-up to address Jiri's recent feedback [1] on
> the flowi6_tos issue, that it is not used for IPv6 route lookups.
> The three patches fix all current users of flowi6_tos and remove
> the define to avoid any future confusion on this. Tested the vxlan
> and geneve ones with IPv6 routing rules. For details, please see
> individual patches.
> 
> [ As fixes are currently applied against net-next tree, I've rebased
>   it against that. ]
> 
> Thanks!
> 
>   [1] http://patchwork.ozlabs.org/patch/592055/

Series applied, thanks Daniel.
