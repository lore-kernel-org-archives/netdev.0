From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] 6lowpan: reassembly: fix return of init
 function
Date: Fri, 07 Mar 2014 17:11:46 -0500 (EST)
Message-ID: <20140307.171146.1685614463447589267.davem@davemloft.net>
References: <1394186814-18745-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbaCGWLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 17:11:48 -0500
In-Reply-To: <1394186814-18745-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Fri,  7 Mar 2014 11:06:54 +0100

> This patch adds a missing return after fragmentation init. Otherwise we
> register a sysctl interface and deregister it afterwards which makes no
> sense.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
> Changes since v2:
>  - remove goto out label and use return ret instead.

Applied, thanks.
