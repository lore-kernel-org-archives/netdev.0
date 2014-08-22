From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Fix endian issues with rx_no_buffer statistic
Date: Fri, 22 Aug 2014 11:28:19 -0700 (PDT)
Message-ID: <20140822.112819.1726017415445947463.davem@davemloft.net>
References: <20140822113652.7e4bdc78@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, paulus@samba.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbaHVS2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:28:20 -0400
In-Reply-To: <20140822113652.7e4bdc78@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Fri, 22 Aug 2014 11:36:52 +1000

> Hidden away in the last 8 bytes of the buffer_list page is a solitary
> statistic. It needs to be byte swapped or else ethtool -S will
> produce numbers that terrify the user.
> 
> Since we do this in multiple places, create a helper function with a
> comment explaining what is going on.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>

Applied, thanks Anton.
