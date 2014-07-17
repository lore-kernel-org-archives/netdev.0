From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: Drop unnecessary return value from
 ndo_dflt_fdb_del
Date: Wed, 16 Jul 2014 23:13:49 -0700 (PDT)
Message-ID: <20140716.231349.266229774123578042.davem@davemloft.net>
References: <20140715221417.22730.78891.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678AbaGQGNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:13:50 -0400
In-Reply-To: <20140715221417.22730.78891.stgit@ahduyck-cp2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 15 Jul 2014 15:15:20 -0700

> This change cleans up ndo_dflt_fdb_del to drop the ENOTSUPP return value since
> that isn't actually returned anywhere in the code.  As a result we are able to
> drop a few lines by just defaulting this to -EINVAL.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks.
