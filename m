From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: fix error recovery when t4_fw_hello returns a
 positive value
Date: Fri, 03 May 2013 16:13:40 -0400 (EDT)
Message-ID: <20130503.161340.725942468744060225.davem@davemloft.net>
References: <1367604664-22368-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com,
	linux-kernel@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934274Ab3ECUNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:13:42 -0400
In-Reply-To: <1367604664-22368-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Fri,  3 May 2013 15:11:04 -0300

> Since commit 636f9d371f70f22961fd598fe18380057518ca31 ("cxgb4: Add
> support for T4 configuration file"), t4_fw_hello may return a positive
> value instead of 0 for success. The recovery code tests only for zero
> and fails recovery for any other value.
> 
> This fix tests for negative error values and fails only on those cases.
> Error recovery after an error injection works after this change.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied.
