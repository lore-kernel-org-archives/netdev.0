From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Remove the meaningless code
Date: Sun, 28 Jun 2015 16:49:39 -0700 (PDT)
Message-ID: <20150628.164939.1817216986237397063.davem@davemloft.net>
References: <1435360646-7831-1-git-send-email-liang.z.li@intel.com>
	<558D6C86.4040802@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liang.z.li@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	andrew.bennieston@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbbF1Xtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 19:49:40 -0400
In-Reply-To: <558D6C86.4040802@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Fri, 26 Jun 2015 16:15:18 +0100

> On 27/06/15 00:17, Liang Li wrote:
>> The function netif_set_real_num_tx_queues() will return -EINVAL if
>> the second parameter < 1, so call this function with the second
>> parameter set to 0 is meaningless.
> 
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Applied.
