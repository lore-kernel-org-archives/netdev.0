From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: fix warning on 32-bit arch
Date: Wed, 11 Jun 2014 15:14:35 -0700 (PDT)
Message-ID: <20140611.151435.1266704205978520305.davem@davemloft.net>
References: <1402517804-4301-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, fengguang.wu@intel.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbaFKWOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:14:36 -0400
In-Reply-To: <1402517804-4301-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 11 Jun 2014 13:16:44 -0700

> fix compiler warning on 32-bit architectures:
> 
> net/core/filter.c: In function '__sk_run_filter':
> net/core/filter.c:540:22: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
> net/core/filter.c:550:22: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
> net/core/filter.c:560:22: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
