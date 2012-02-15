From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH V4 12/13] netfront: multi page ring support.
Date: Wed, 15 Feb 2012 17:52:12 -0500 (EST)
Message-ID: <20120215.175212.1236819573371947275.davem@davemloft.net>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	<1328201363-13915-13-git-send-email-wei.liu2@citrix.com>
	<20120215224253.GA18762@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, ian.campbell@citrix.com
To: konrad.wilk@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab2BOWwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 17:52:25 -0500
In-Reply-To: <20120215224253.GA18762@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Wed, 15 Feb 2012 17:42:53 -0500

> @@ -29,6 +29,8 @@
>   * IN THE SOFTWARE.
>   */
>  
> +#define DEBUG 1
> +
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/netdevice.h>

This is never appropriate.
