From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] xen-netfront: Remove the meaningless code
Date: Fri, 26 Jun 2015 16:15:18 +0100
Message-ID: <558D6C86.4040802@citrix.com>
References: <1435360646-7831-1-git-send-email-liang.z.li@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	<konrad.wilk@oracle.com>, <boris.ostrovsky@oracle.com>,
	<andrew.bennieston@citrix.com>, <wei.liu2@citrix.com>,
	<davem@davemloft.net>
To: Liang Li <liang.z.li@intel.com>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53534 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbbFZPPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 11:15:22 -0400
In-Reply-To: <1435360646-7831-1-git-send-email-liang.z.li@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/06/15 00:17, Liang Li wrote:
> The function netif_set_real_num_tx_queues() will return -EINVAL if
> the second parameter < 1, so call this function with the second
> parameter set to 0 is meaningless.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
